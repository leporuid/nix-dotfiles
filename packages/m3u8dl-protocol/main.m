#import <Cocoa/Cocoa.h>
#import <sys/stat.h>
#import <unistd.h>

#ifndef FFMPEG_BIN_PATH
#define FFMPEG_BIN_PATH "/run/current-system/sw/bin/ffmpeg"
#endif

#ifndef EXTRA_BIN_PATH
#define EXTRA_BIN_PATH "/run/current-system/sw/bin"
#endif

static NSString *getAppPrefixDir(void) {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    if ([bundlePath hasSuffix:@".app"]) {
        return [[bundlePath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    }
    NSString *execPath = [[NSBundle mainBundle] executablePath];
    return [[execPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
}

static void ensureRegistered(void) {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    if (![bundlePath hasSuffix:@".app"]) return;

    NSString *home = NSHomeDirectory();
    NSString *stampDir = [home stringByAppendingPathComponent:@".cache/n-m3u8dl-re"];
    NSString *stampFile = [stampDir stringByAppendingPathComponent:@"registered_path"];
    NSString *lsregister = @"/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister";

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:lsregister] && [fm fileExistsAtPath:bundlePath]) {
        NSString *currentStamp = @"";
        if ([fm fileExistsAtPath:stampFile]) {
            currentStamp = [[NSString stringWithContentsOfFile:stampFile encoding:NSUTF8StringEncoding error:nil] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        if (![currentStamp isEqualToString:bundlePath]) {
            [fm createDirectoryAtPath:stampDir withIntermediateDirectories:YES attributes:nil error:nil];
            NSTask *task = [[NSTask alloc] init];
            task.executableURL = [NSURL fileURLWithPath:lsregister];
            task.arguments = @[ @"-f", bundlePath ];
            [task launchAndReturnError:nil];
            [task waitUntilExit];
            if (task.terminationStatus == 0) {
                [bundlePath writeToFile:stampFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }
    }
}

static void notifyUser(NSString *title, NSString *message) {
    NSString *script = [NSString stringWithFormat:@"display notification \"%@\" with title \"%@\"",
        [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""],
        [title stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
    NSTask *task = [[NSTask alloc] init];
    task.executableURL = [NSURL fileURLWithPath:@"/usr/bin/osascript"];
    task.arguments = @[ @"-e", script ];
    [task launchAndReturnError:nil];
}

static NSString *tryBase64Decode(NSString *val) {
    val = [val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (val.length == 0) return @"";
    NSString *padded = [val stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    padded = [padded stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    NSUInteger padLen = (4 - (padded.length % 4)) % 4;
    if (padLen > 0) {
        padded = [padded stringByAppendingString:[@"====" substringToIndex:padLen]];
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:padded options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (str && str.length > 0) {
            return str;
        }
    }
    return val;
}

static NSArray<NSString *> *splitCommandLineArguments(NSString *cmdLine) {
    NSMutableArray<NSString *> *args = [NSMutableArray array];
    NSMutableString *current = [NSMutableString string];
    BOOL inSingle = NO;
    BOOL inDouble = NO;
    BOOL escaping = NO;
    NSUInteger len = cmdLine.length;

    for (NSUInteger i = 0; i < len; i++) {
        unichar c = [cmdLine characterAtIndex:i];
        if (escaping) {
            [current appendFormat:@"%C", c];
            escaping = NO;
            continue;
        }
        if (c == '\\' && !inSingle) {
            escaping = YES;
            continue;
        }
        if (c == '\'' && !inDouble) {
            inSingle = !inSingle;
            continue;
        }
        if (c == '"' && !inSingle) {
            inDouble = !inDouble;
            continue;
        }
        if (isspace(c) && !inSingle && !inDouble) {
            if (current.length > 0) {
                [args addObject:[current copy]];
                [current setString:@""];
            }
            continue;
        }
        [current appendFormat:@"%C", c];
    }
    if (current.length > 0) {
        [args addObject:[current copy]];
    }
    return args;
}

static NSArray<NSString *> *normalizeArgs(NSArray<NSString *> *args) {
    NSString *home = NSHomeDirectory();
    NSMutableArray<NSString *> *normalized = [NSMutableArray array];
    BOOL hasSaveDir = NO;
    BOOL hasFfmpeg = NO;

    NSUInteger count = args.count;
    for (NSUInteger i = 0; i < count; i++) {
        NSString *arg = args[i];
        if ([arg containsString:@"%USERPROFILE%"]) {
            arg = [arg stringByReplacingOccurrencesOfString:@"%USERPROFILE%" withString:home];
            arg = [arg stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        }
        if (([arg isEqualToString:@"--save-dir"] || [arg isEqualToString:@"--tmp-dir"]) && i + 1 < count) {
            if ([arg isEqualToString:@"--save-dir"]) hasSaveDir = YES;
            NSString *nxt = args[i + 1];
            if ([nxt containsString:@"%USERPROFILE%"]) {
                nxt = [nxt stringByReplacingOccurrencesOfString:@"%USERPROFILE%" withString:home];
                nxt = [nxt stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            }
            if ([nxt hasPrefix:@"~"]) {
                nxt = [home stringByAppendingPathComponent:[nxt substringFromIndex:1]];
            }
            [normalized addObject:arg];
            [normalized addObject:nxt];
            i++;
            continue;
        }
        if ([arg isEqualToString:@"--ffmpeg-binary-path"]) hasFfmpeg = YES;
        if ([arg isEqualToString:@"--cat-catch-test"]) continue;

        [normalized addObject:arg];
    }

    if (!hasSaveDir) {
        [normalized addObject:@"--save-dir"];
        [normalized addObject:[home stringByAppendingPathComponent:@"Downloads"]];
    }
    NSString *ffmpegPath = @FFMPEG_BIN_PATH;
    if (!hasFfmpeg && [[NSFileManager defaultManager] fileExistsAtPath:ffmpegPath]) {
        [normalized addObject:@"--ffmpeg-binary-path"];
        [normalized addObject:ffmpegPath];
    }
    return normalized;
}

static NSArray<NSString *> *buildArgsFromFields(NSString *url, NSString *title, NSString *referer, NSString *cookie) {
    NSMutableArray<NSString *> *built = [NSMutableArray array];
    if (url.length > 0) [built addObject:url];
    if (title.length > 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\\\/:*?\"<>|]+" options:0 error:nil];
        NSString *safeTitle = [regex stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, title.length) withTemplate:@"_"];
        safeTitle = [safeTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *saveName = [NSString stringWithFormat:@"%@_%ld", safeTitle, (long)[[NSDate date] timeIntervalSince1970]];
        [built addObject:@"--save-name"];
        [built addObject:saveName];
    }
    if (referer.length > 0) {
        [built addObject:@"-H"];
        [built addObject:[NSString stringWithFormat:@"Referer: %@", referer]];
    }
    if (cookie.length > 0) {
        [built addObject:@"-H"];
        [built addObject:[NSString stringWithFormat:@"Cookie: %@", cookie]];
    }
    [built addObjectsFromArray:@[ @"--auto-select", @"--del-after-done", @"--no-log" ]];
    return normalizeArgs(built);
}

static NSArray<NSString *> *parseUrlPayload(NSString *rawUrl, BOOL *outInteractive) {
    BOOL interactive = [[[NSProcessInfo processInfo] environment][@"M3U8DL_INTERACTIVE"] isEqualToString:@"1"];
    NSRegularExpression *schemeRegex = [NSRegularExpression regularExpressionWithPattern:@"^(m3u8dlre|m3u8dl)://?" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *payload = [schemeRegex stringByReplacingMatchesInString:rawUrl options:0 range:NSMakeRange(0, rawUrl.length) withTemplate:@""];

    if ([payload hasPrefix:@"?"] || [payload hasPrefix:@"download?"] || ([payload containsString:@"="] && [payload containsString:@"&"] && ![payload hasPrefix:@"\""])) {
        NSString *qsPart = payload;
        NSRange qMark = [payload rangeOfString:@"?"];
        if (qMark.location != NSNotFound) {
            qsPart = [payload substringFromIndex:qMark.location + 1];
        }

        NSMutableDictionary<NSString *, NSString *> *params = [NSMutableDictionary dictionary];
        NSArray *pairs = [qsPart componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *kv = [pair componentsSeparatedByString:@"="];
            if (kv.count == 2) {
                params[kv[0]] = [kv[1] stringByRemovingPercentEncoding];
            }
        }

        if (params[@"interactive"] || params[@"popup"]) {
            NSString *s = params[@"interactive"] ?: params[@"popup"];
            interactive = [s isEqualToString:@"1"] || [s isEqualToString:@"true"] || [s isEqualToString:@"yes"];
        }
        if (outInteractive) *outInteractive = interactive;

        if (params[@"args"]) {
            NSString *decoded = tryBase64Decode(params[@"args"]);
            return normalizeArgs(splitCommandLineArguments(decoded));
        }

        NSString *url = tryBase64Decode(params[@"url"] ?: @"");
        NSString *title = tryBase64Decode(params[@"title"] ?: @"");
        NSString *referer = tryBase64Decode(params[@"referer"] ?: @"");
        NSString *cookie = tryBase64Decode(params[@"cookie"] ?: @"");
        return buildArgsFromFields(url, title, referer, cookie);
    }

    NSString *unquoted = [payload stringByRemovingPercentEncoding];
    NSString *trimmed = [unquoted stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    NSString *decoded = tryBase64Decode(trimmed);
    if (![decoded containsString:@"http"] && ![decoded containsString:@"--"] && ![decoded containsString:@"-H"] && ![decoded containsString:@"/"]) {
        decoded = unquoted;
    }
    if (outInteractive) *outInteractive = interactive;
    return normalizeArgs(splitCommandLineArguments(decoded));
}

static NSString *getBTTVariable(NSString *name) {
    NSString *script = [NSString stringWithFormat:@"tell application \"BetterTouchTool\" to get_string_variable \"%@\"", name];
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource:script];
    NSDictionary *err = nil;
    NSAppleEventDescriptor *res = [as executeAndReturnError:&err];
    if (res && [res stringValue]) {
        NSString *val = [res stringValue];
        if (![val isEqualToString:@"missing value"]) return val;
    }
    return @"";
}

static void clearBTTVariables(NSArray<NSString *> *names) {
    NSMutableString *script = [NSMutableString stringWithString:@"tell application \"BetterTouchTool\"\n"];
    for (NSString *name in names) {
        [script appendFormat:@"  set_string_variable \"%@\" to \"\"\n", name];
    }
    [script appendString:@"end tell"];
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource:script];
    [as executeAndReturnError:nil];
}

static NSArray<NSString *> *parseFromBTT(BOOL *outInteractive) {
    NSArray *varNames = @[
        @"cat_args", @"args",
        @"cat_url", @"url",
        @"cat_title", @"title",
        @"cat_referer", @"referer",
        @"cat_cookie", @"cookie",
        @"cat_interactive", @"interactive",
        @"cat_popup", @"popup"
    ];
    NSMutableDictionary<NSString *, NSString *> *vals = [NSMutableDictionary dictionary];
    for (NSString *v in varNames) {
        vals[v] = getBTTVariable(v);
    }
    clearBTTVariables(varNames);

    NSString *interactiveVal = vals[@"cat_interactive"].length > 0 ? vals[@"cat_interactive"] : (vals[@"interactive"].length > 0 ? vals[@"interactive"] : (vals[@"cat_popup"].length > 0 ? vals[@"cat_popup"] : vals[@"popup"]));
    BOOL interactive = [interactiveVal isEqualToString:@"1"] || [interactiveVal isEqualToString:@"true"] || [interactiveVal isEqualToString:@"yes"] || [[[NSProcessInfo processInfo] environment][@"M3U8DL_INTERACTIVE"] isEqualToString:@"1"];
    if (outInteractive) *outInteractive = interactive;

    NSString *rawArgs = vals[@"cat_args"].length > 0 ? vals[@"cat_args"] : vals[@"args"];
    if (rawArgs.length > 0) {
        NSString *decoded = tryBase64Decode([rawArgs stringByRemovingPercentEncoding]);
        return normalizeArgs(splitCommandLineArguments(decoded));
    }

    NSString *url = tryBase64Decode([vals[@"cat_url"].length > 0 ? vals[@"cat_url"] : vals[@"url"] stringByRemovingPercentEncoding]);
    NSString *title = tryBase64Decode([vals[@"cat_title"].length > 0 ? vals[@"cat_title"] : vals[@"title"] stringByRemovingPercentEncoding]);
    NSString *referer = tryBase64Decode([vals[@"cat_referer"].length > 0 ? vals[@"cat_referer"] : vals[@"referer"] stringByRemovingPercentEncoding]);
    NSString *cookie = tryBase64Decode([vals[@"cat_cookie"].length > 0 ? vals[@"cat_cookie"] : vals[@"cookie"] stringByRemovingPercentEncoding]);
    return buildArgsFromFields(url, title, referer, cookie);
}

static void installBTTTrigger(void) {
    NSDictionary *triggerObj = @{
        @"BTTTriggerType": @643,
        @"BTTTriggerTypeDescription": @"Named Trigger: cat-catch-dl",
        @"BTTTriggerClass": @"BTTTriggerTypeOtherTriggers",
        @"BTTTriggerName": @"cat-catch-dl",
        @"BTTEnabled": @1,
        @"BTTActionsToExecute": @[
            @{
                @"BTTPredefinedActionType": @206,
                @"BTTPredefinedActionName": @"Execute Shell Script  or  Task",
                @"BTTShellTaskActionScript": @"export PATH=\"/etc/profiles/per-user/$USER/bin:$HOME/.nix-profile/bin:/run/current-system/sw/bin:$PATH\"\nm3u8dl-handler --from-btt",
                @"BTTShellTaskActionConfig": @"/bin/sh:::-c:::-:::"
            }
        ]
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:triggerObj options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *encoded = [jsonStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"btt://add_new_trigger/?json=%@", encoded]];
    [[NSWorkspace sharedWorkspace] openURL:url];
    printf("Sent cat-catch-dl Named Trigger registration to BetterTouchTool.\n");
}

static void launchDownload(NSArray<NSString *> *cliArgs, BOOL interactive) {
    ensureRegistered();
    if (cliArgs.count == 0) {
        notifyUser(@"N_m3u8DL-RE", @"No valid download parameters received");
        return;
    }

    NSString *prefixDir = getAppPrefixDir();
    NSString *binaryPath = [prefixDir stringByAppendingPathComponent:@"bin/N_m3u8DL-RE"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:binaryPath]) {
        binaryPath = @"N_m3u8DL-RE";
    }

    // Default: Background download mode (no popup terminal window)
    if (!interactive) {
        NSMutableArray *bgArgs = [NSMutableArray arrayWithArray:cliArgs];
        if (![bgArgs containsObject:@"--auto-select"]) {
            [bgArgs addObject:@"--auto-select"];
        }

        NSString *title = @"";
        NSUInteger nameIdx = [bgArgs indexOfObject:@"--save-name"];
        if (nameIdx != NSNotFound && nameIdx + 1 < bgArgs.count) {
            title = bgArgs[nameIdx + 1];
        }

        NSMutableArray *fullCmd = [NSMutableArray arrayWithObject:binaryPath];
        [fullCmd addObjectsFromArray:bgArgs];

        NSMutableString *quotedCmd = [NSMutableString string];
        for (NSUInteger i = 0; i < fullCmd.count; i++) {
            NSString *arg = fullCmd[i];
            NSString *escaped = [arg stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"];
            if (i > 0) [quotedCmd appendString:@" "];
            [quotedCmd appendFormat:@"'%@'", escaped];
        }

        char tmpTemplate[] = "/tmp/n-m3u8dl-bg-XXXXXX.sh";
        int fd = mkstemps(tmpTemplate, 3);
        if (fd == -1) return;
        NSString *runnerPath = [NSString stringWithUTF8String:tmpTemplate];

        NSString *startMsg = title.length > 0
            ? [NSString stringWithFormat:@"Starting background download: %@", title]
            : @"Starting background download...";
        notifyUser(@"N_m3u8DL-RE", startMsg);

        NSMutableString *shContent = [NSMutableString string];
        [shContent appendString:@"#!/bin/bash\n"];
        [shContent appendFormat:@"export PATH=\"%@:%@:$PATH\"\n", [prefixDir stringByAppendingPathComponent:@"bin"], @EXTRA_BIN_PATH];
        [shContent appendFormat:@"%@\n", quotedCmd];
        [shContent appendString:@"status=$?\n"];
        [shContent appendString:@"if [ $status -eq 0 ]; then\n"];
        if (title.length > 0) {
            [shContent appendFormat:@"  /usr/bin/osascript -e 'display notification \"✅ Download complete: %@\" with title \"N_m3u8DL-RE\"'\n", [title stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
        } else {
            [shContent appendString:@"  /usr/bin/osascript -e 'display notification \"✅ Download complete!\" with title \"N_m3u8DL-RE\"'\n"];
        }
        [shContent appendString:@"else\n"];
        [shContent appendString:@"  /usr/bin/osascript -e 'display notification \"❌ Download failed. Check log file.\" with title \"N_m3u8DL-RE\"'\n"];
        [shContent appendString:@"fi\n"];
        [shContent appendFormat:@"rm -f '%@'\n", runnerPath];

        write(fd, shContent.UTF8String, shContent.length);
        close(fd);
        chmod(runnerPath.UTF8String, 0755);

        // Spawn completely detached in the background
        NSTask *bgTask = [[NSTask alloc] init];
        bgTask.executableURL = [NSURL fileURLWithPath:@"/bin/bash"];
        bgTask.arguments = @[ runnerPath ];
        bgTask.standardInput = [NSFileHandle fileHandleWithNullDevice];
        bgTask.standardOutput = [NSFileHandle fileHandleWithNullDevice];
        bgTask.standardError = [NSFileHandle fileHandleWithNullDevice];
        [bgTask launchAndReturnError:nil];
        return;
    }

    // Opt-in: Interactive terminal window mode (Ghostty or Terminal.app)
    NSMutableArray *fullCmd = [NSMutableArray arrayWithObject:binaryPath];
    [fullCmd addObjectsFromArray:cliArgs];

    NSMutableString *quotedCmd = [NSMutableString string];
    for (NSUInteger i = 0; i < fullCmd.count; i++) {
        NSString *arg = fullCmd[i];
        NSString *escaped = [arg stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"];
        if (i > 0) [quotedCmd appendString:@" "];
        [quotedCmd appendFormat:@"'%@'", escaped];
    }

    char tmpTemplate[] = "/tmp/n-m3u8dl-ui-XXXXXX.sh";
    int fd = mkstemps(tmpTemplate, 3);
    if (fd == -1) return;
    NSString *runnerPath = [NSString stringWithUTF8String:tmpTemplate];

    NSMutableString *shContent = [NSMutableString string];
    [shContent appendString:@"#!/bin/bash\n"];
    [shContent appendFormat:@"export PATH=\"%@:%@:$PATH\"\n", [prefixDir stringByAppendingPathComponent:@"bin"], @EXTRA_BIN_PATH];
    [shContent appendString:@"echo '🚀 N_m3u8DL-RE starting download...'\n"];
    [shContent appendFormat:@"echo \"%@\"\n", [quotedCmd stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
    [shContent appendString:@"echo ''\n"];
    [shContent appendFormat:@"%@\n", quotedCmd];
    [shContent appendString:@"status=$?\n"];
    [shContent appendString:@"if [ $status -eq 0 ]; then\n"];
    [shContent appendString:@"  /usr/bin/osascript -e 'display notification \"✅ Download complete!\" with title \"N_m3u8DL-RE\"'\n"];
    [shContent appendString:@"  sleep 1\n"];
    [shContent appendString:@"else\n"];
    [shContent appendString:@"  /usr/bin/osascript -e 'display notification \"❌ Download error occurred. Check terminal output.\" with title \"N_m3u8DL-RE\"'\n"];
    [shContent appendString:@"  echo ''\n"];
    [shContent appendString:@"  read -n 1 -s -r -p 'Press any key to close...'\n"];
    [shContent appendString:@"fi\n"];
    [shContent appendFormat:@"rm -f '%@'\n", runnerPath];

    write(fd, shContent.UTF8String, shContent.length);
    close(fd);
    chmod(runnerPath.UTF8String, 0755);

    NSString *ghosttyApp = @"/Applications/Ghostty.app";
    if ([[NSFileManager defaultManager] fileExistsAtPath:ghosttyApp]) {
        NSTask *openTask = [[NSTask alloc] init];
        openTask.executableURL = [NSURL fileURLWithPath:@"/usr/bin/open"];
        openTask.arguments = @[ @"-na", ghosttyApp, @"--args", @"-e", @"/bin/bash", runnerPath ];
        [openTask launchAndReturnError:nil];
    } else {
        NSString *appleScript = [NSString stringWithFormat:@"tell application \"Terminal\" to do script \"%@\" & activate", runnerPath];
        NSAppleScript *as = [[NSAppleScript alloc] initWithSource:appleScript];
        [as executeAndReturnError:nil];
    }
}

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager]
        setEventHandler:self
            andSelector:@selector(handleGetURLEvent:withReplyEvent:)
          forEventClass:kInternetEventClass
             andEventID:kAEGetURL];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event
           withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    (void)replyEvent;
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    if (url) {
        BOOL interactive = NO;
        NSArray *args = parseUrlPayload(url, &interactive);
        launchDownload(args, interactive);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSApp terminate:nil];
    });
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    (void)notification;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSApp terminate:nil];
    });
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc >= 2) {
            NSString *arg1 = [NSString stringWithUTF8String:argv[1]];
            if ([arg1 isEqualToString:@"--register"] || [arg1 isEqualToString:@"--register-protocol"]) {
                ensureRegistered();
                printf("Registered M3U8DLProtocol.app with macOS LaunchServices.\n");
                return 0;
            }
            if ([arg1 isEqualToString:@"--install-btt-trigger"]) {
                installBTTTrigger();
                return 0;
            }
            if ([arg1 isEqualToString:@"--from-btt"]) {
                BOOL interactive = NO;
                NSArray *args = parseFromBTT(&interactive);
                launchDownload(args, interactive);
                return 0;
            }
            BOOL interactive = NO;
            NSArray *args = parseUrlPayload(arg1, &interactive);
            launchDownload(args, interactive);
            return 0;
        }

        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyProhibited];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}
