# Dynamic target volume selection for gallery-dl / gallery-ai (/Volumes/HDD or /Volumes/SDXC)
function __gdl_target_dir
    if test -d /Volumes/HDD
        echo /Volumes/HDD/Gallery-dl
    else if test -d /Volumes/SDXC
        echo /Volumes/SDXC/Gallery-dl
    else
        echo "$HOME/Pictures/Gallery-dl"
    end
end

function gdl --wraps gallery-dl -d "gallery-dl with auto-detected external volume (/Volumes/HDD or /Volumes/SDXC)"
    set -l target (__gdl_target_dir)
    gallery-dl --dest "$target" $argv
end

function gdl-hdd --wraps gallery-dl -d "gallery-dl explicitly targeting /Volumes/HDD"
    gallery-dl --dest /Volumes/HDD/Gallery-dl $argv
end

function gdl-sdxc --wraps gallery-dl -d "gallery-dl explicitly targeting /Volumes/SDXC"
    gallery-dl --dest /Volumes/SDXC/Gallery-dl $argv
end
