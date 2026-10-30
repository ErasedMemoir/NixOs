# Default application for each file type.
let
  associate =
    app: types:
    builtins.listToAttrs (
      map (type: {
        name = type;
        value = app;
      }) types
    );
in
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      associate "org.pwmt.zathura-pdf-mupdf.desktop" [ "application/pdf" ]
      // associate "imv.desktop" [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/bmp"
        "image/tiff"
        "image/svg+xml"
      ]
      // associate "mpv.desktop" [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/x-msvideo"
        "audio/mpeg"
        "audio/flac"
        "audio/ogg"
        "audio/x-wav"
        "audio/mp4"
      ]
      // associate "writer.desktop" [
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/msword"
        "application/vnd.oasis.opendocument.text"
        "application/rtf"
      ]
      // associate "calc.desktop" [
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.ms-excel"
        "application/vnd.oasis.opendocument.spreadsheet"
        "text/csv"
      ]
      // associate "impress.desktop" [
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "application/vnd.ms-powerpoint"
        "application/vnd.oasis.opendocument.presentation"
      ]
      // associate "code.desktop" [
        "text/plain"
        "text/markdown"
        "application/json"
        "application/x-shellscript"
        "text/x-python"
        "text/x-nix"
      ]
      // associate "firefox.desktop" [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ]
      // associate "org.gnome.FileRoller.desktop" [
        "application/zip"
        "application/vnd.rar"
        "application/x-7z-compressed"
        "application/x-tar"
        "application/gzip"
        "application/x-xz"
      ]
      // associate "thunar.desktop" [ "inode/directory" ]
      // associate "discord.desktop" [ "x-scheme-handler/discord" ]
      // associate "lunarclient.desktop" [
        "x-scheme-handler/lunarclient"
        "x-scheme-handler/discord-562286213059444737"
      ]
      // associate "claude-code-url-handler.desktop" [ "x-scheme-handler/claude-cli" ];
  };
}
