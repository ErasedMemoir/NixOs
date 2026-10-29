# home/claude.nix - Claude Code: package, private toolchain, settings, global memory
{ pkgs, lib, ... }:
let
  # Tools on Claude's PATH only (ripgrep ships with the package); anything else via `nix shell`
  claudeTools = with pkgs; [
    fd
    jq
    ripgrep-all # rga: grep inside PDFs, docx, zip
    poppler-utils # pdftotext, pdftoppm
    mupdf # mutool: render single pages
    imagemagick
    pandoc
    ocrmypdf
    (tesseract.override { enableLanguages = [ "eng" "ita" ]; })
    unstable.markitdown # pptx/docx/xlsx -> markdown
    texliveFull
    nixfmt
    nvd
    (python3.withPackages (ps: with ps; [
      sympy
      numpy
      scipy
      matplotlib
      pymupdf # fitz
    ]))
  ];

  claude-code = pkgs.symlinkJoin {
    name = "claude-code-${pkgs.unstable.claude-code.version}";
    paths = [ pkgs.unstable.claude-code ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/claude --prefix PATH : ${lib.makeBinPath claudeTools}
    '';
    inherit (pkgs.unstable.claude-code) meta;
  };

  # Model | context used | 5h plan usage (Pro limits)
  statusLine = pkgs.writeShellScript "claude-statusline" ''
    ${lib.getExe pkgs.jq} -r '[
      .model.display_name,
      "ctx \(.context_window.used_percentage // 0 | floor)%",
      (.rate_limits.five_hour.used_percentage // empty | "5h \(floor)%")
    ] | join(" | ")'
  '';
in
{
  # Study rules load only inside the University tree
  home.file."Documents/University/CLAUDE.md".text = ''
    # Study Material
    - PDFs & slides: never load whole multi-page PDFs visually. Extract text with `pdftotext -layout` or a `fitz` script; view only specific pages when diagrams matter. Scanned PDFs (no text layer): `ocrmypdf -l ita+eng in.pdf out.pdf` first. Slides/docs (`.pptx`, `.docx`): `markitdown file`.
    - Find which PDF covers a topic with `rga -l 'term'` before opening anything. To see a diagram: `mutool draw -r 100 -o /tmp/p.png file.pdf N`, then view that one page.
    - Math: never guess non-trivial algebra, calculus, matrices, or transforms; verify with `sympy` before answering. Course-specific tools (octave, ngspice, SQL engines, ...) come from `nix shell nixpkgs#<pkg>`.
    - Summaries ("riassunto"): write in Italian as a LaTeX document (`\usepackage[italian]{babel}`, `amsmath`, `siunitx`) with formal definitions, equations, and edge cases; strip academic filler. Save next to the course material, compile with `latexmk -pdf -interaction=nonstopmode`, fix errors, then delete aux files with `latexmk -c`.
  '';

  programs.claude-code = {
    enable = true;
    package = claude-code;

    mcpServers = {
      nixos.command = lib.getExe pkgs.unstable.mcp-nixos;
      context7.command = lib.getExe pkgs.unstable.context7-mcp;
    };

    lspServers = {
      nix = {
        command = lib.getExe pkgs.nixd;
        extensionToLanguage.".nix" = "nix";
      };
    };

    settings = {
      model = "opus";
      # Background model calls and UI noise
      promptSuggestionEnabled = false;
      awaySummaryEnabled = false;
      spinnerTipsEnabled = false;
      feedbackSurveyRate = 0;
      workflowKeywordTriggerEnabled = false;
      statusLine = {
        type = "command";
        command = "${statusLine}";
      };
      env = {
        DISABLE_TELEMETRY = "1";
        DISABLE_ERROR_REPORTING = "1";
      };
      permissions = {
        # Read store sources and the live config without prompts
        additionalDirectories = [
          "/nix/store"
          "/run/current-system"
          "/etc/profiles/per-user"
        ];
        allow = [
          "Bash(rg:*)"
          "Bash(fd:*)"
          "Bash(jq:*)"
          "Bash(rga:*)"
          "Bash(pdftotext:*)"
          "Bash(pdfinfo:*)"
          "Bash(mutool:*)"
          "Bash(markitdown:*)"
          "Bash(latexmk:*)"
          "Bash(nixfmt:*)"
          "Bash(nvd:*)"
          "Bash(git status:*)"
          "Bash(git diff:*)"
          "Bash(git log:*)"
          "Bash(git show:*)"
          "Bash(nix eval:*)"
          "Bash(nix search:*)"
          "Bash(nix flake show:*)"
          "mcp__plugin_claude-code-home-manager_nixos"
          "mcp__plugin_claude-code-home-manager_context7"
        ];
        ask = [
          "Bash(sudo:*)"
          "Bash(git push:*)"
        ];
        deny = [
          "Read(**/.env)"
          "Read(**/.env.*)"
          "Read(~/.ssh/**)"
        ];
      };
    };

    context = ''
      # Behavior & Tone
      - Act as a critical, direct peer engineer. Never validate flawed logic, bad premises, or suboptimal code.
      - Zero fluff: no greetings, compliments, apologies, or closing summaries. Lead with the answer, diff, or equation.
      - Do not repeat unchanged code. Output only targeted changes or minimal diffs.

      # Code Changes
      - Make the smallest change that solves the problem well; prefer simple over clever, no unnecessary abstractions.
      - Do not refactor unrelated code or modify unrelated files. Preserve existing style and structure.
      - Do not add features, tests, comments, or docs I did not request.
      - Dependencies: prefer a popular, well-maintained one over reimplementing substantial functionality, never for trivial gains. Explain why and wait for my approval before adding it.

      # System: NixOS
      - Config is a flake at `/etc/nixos` (git repo, user-owned). Home Manager runs as a NixOS module; `import-tree` auto-loads every file in `modules/nixos/` and `modules/home/`. New files must be `git add`ed or the flake won't see them.
      - Root is ephemeral (preservation, persisted under `/data`); `$HOME` is persistent.
      - Any missing tool is one command away: `nix shell nixpkgs#<pkg> -c <cmd>`. Never `apt`, `pip install`, `npm i -g`. Projects: use the repo's devShell (`nix develop -c <cmd>`); if none, propose a minimal `flake.nix`.
      - Look up options and packages with the `nixos` MCP instead of guessing; library APIs with `context7`.
      - Never run `sudo` or `nixos-rebuild switch`. Validate with `nixos-rebuild build --flake /etc/nixos#nixos`, summarize with `nvd diff /run/current-system result`, then give me the switch command.

      # Tools
      - On PATH beyond the usual: `rga` (grep inside PDFs/docx), `markitdown`, `mutool`, `ocrmypdf`, TeX Live, `python3` with sympy/numpy/scipy/matplotlib/fitz.
      - Keep context lean: locate with `rg`/`rga`, then read line ranges; downscale images before viewing.
    '';
  };
}
