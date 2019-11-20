#!/usr/bin/env ruby
############################################################################
# FYI this is a VERY hacky/untested script not intended for distribution   #
############################################################################
# usage: plasma-randwp <path_to_dir_with_image_files>
#   where <path_to_dir_with_image_files> defaults to ~/Pictures
# executes a command that runs some javascript to set the wallpaper used by
# KDE plasma to a random image file (jpg|png) found in given path.
# Sets same wallpaper for each virtual desktop, should be easy to change

DEFAULT_PATH = File.expand_path("~/Wallpapers")

class String
  def image_file?
    match?(/\A.*\.(jpg|png)\z/)
  end
end

def set_wallpaper(filename_fullpath)
  system([
    "dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string:",
    "var Desktops = desktops();",
    "for (i=0;i<Desktops.length;i++) {",
    "d = Desktops[i];",
    "d.wallpaperPlugin = \"org.kde.image\";",
    "d.currentConfigGroup = Array(\"Wallpaper\",",
    "\"org.kde.image\",",
    "\"General\");",
    "d.writeConfig(\"Image\", \"file://#{filename_fullpath}\");",
    "}'",
  ].join("\n"))
end

begin
  arg = ARGV.first || DEFAULT_PATH
  wallpaper_directory = arg.end_with?("/") ? arg : "#{arg}/"
  wallpaper_fullpath = wallpaper_directory + Dir.entries(wallpaper_directory).select(&:image_file?).sample.to_s
rescue
  abort "Directory #{arg} not found"
end

set_wallpaper(wallpaper_fullpath)
