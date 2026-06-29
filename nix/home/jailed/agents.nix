{
  lib,
  system,
  agent-sandbox,
  claude-code,
  pkgsUnstable,
  ...
}:
let
  sbx = agent-sandbox.lib.${system};

  start = pkgsUnstable.writeShellScriptBin "start" ''
    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
      echo "Env. var CLAUDE_CODE_OAUTH_TOKEN not defined." >&2
      exit 1
    fi

    claude --dangerously-skip-permissions
  '';

  claude-jailed = sbx.mkSandbox {
    pkg = pkgsUnstable.zsh;

    binName = "zsh";
    outName = "claude-jailed";

    allowedPackages = [
      start
      claude-code
      pkgsUnstable.coreutils
      pkgsUnstable.findutils
      pkgsUnstable.gawk
      pkgsUnstable.git
      pkgsUnstable.zsh
      pkgsUnstable.bash
      pkgsUnstable.ripgrep
    ];

    allowNix = true;

    rwDirs = [
      "$HOME/.config/claude"
      "$HOME/.config/zsh/.antidote"
    ];

    roFiles = [
      "/etc/os-release"
      "$HOME/.zshenv"
      "$HOME/.config/zsh/.antidote"
      "$HOME/.config/zsh/.zplugins"
      "$HOME/.config/zsh/.zplugins-snapshot"
      "$HOME/.config/zsh/.zshenv"
      "$HOME/.config/zsh/.zshrc"
      "$HOME/.config/zsh/.p10k.zsh"
      "$HOME/.config/zsh/.zshrc-keybindings.zsh"
    ];

    env = {
      JAILED = true;
      CLAUDE_CODE_OAUTH_TOKEN = "$CLAUDE_CODE_OAUTH_TOKEN";
      CLAUDE_CONFIG_DIR = "$HOME/config/claude";

      GIT_AUTHOR_IDENT = "gabyx-agent";
      GIT_COMMITER_IDENT = "gabyx-agent";

      LOCALE_ARCHIVE = "${pkgsUnstable.glibcLocales}/lib/locale/locale-archive";
      GITSTATUS_DAEMON = "$GITSTATUS_DAEMON";
    };

    allowedDomains = {
      "anthropic.com" = "*";
      "claude.com" = "*";
      "github.com" = [
        "GET"
        "HEAD"
      ];
      "githubusercontent.com" = [
        "GET"
        "HEAD"
      ];
    }
    // docker-sbx-policy;
  };

  docker-sbx-policy = lib.genAttrs [
    # ── AI services ───────────────────────────────────────────
    "openai.com"
    "chatgpt.com"
    "oaistatic.com"
    "oaiusercontent.com"
    "cdn.openaimerge.com"
    "cursor.com"
    "cursor.sh"
    "factory.ai"
    "api.perplexity.ai"
    "api.workos.com"
    "models.dev"
    "claude.com"
    "downloads.claude.ai"
    "api.anthropic.com"
    "mcp-proxy.anthropic.com"
    "statsig.anthropic.com"
    "gemini.google.com"
    "generativelanguage.googleapis.com"
    "play.googleapis.com"

    # ── Language package managers ─────────────────────────────
    "npmjs.com"
    "npmjs.org"
    "yarnpkg.com"
    "bun.sh"
    "nodejs.org"
    "nodesource.com"
    "npm.duckdb.org"
    "unpkg.com"
    "pypi.org"
    "pypi.python.org"
    "pythonhosted.org"
    "pypa.io"
    "astral.sh"
    "crates.io"
    "rustup.rs"
    "static.rust-lang.org"
    "golang.org"
    "pkg.go.dev"
    "goproxy.io"
    "rubygems.org"
    "ruby-lang.org"
    "rubyonrails.org"
    "maven.org"
    "gradle.org"
    "apache.org"
    "spring.io"
    "eclipse.org"
    "java.com"
    "java.net"
    "dot.net"
    "dotnet.microsoft.com"
    "nuget.org"
    "hex.pm"
    "haskell.org"
    "cpan.org"
    "metacpan.org"
    "packagist.org"
    "packagist.com"
    "cocoapods.org"
    "pub.dev"
    "swift.org"
    "ziglang.org"
    "tuf-repo-cdn.sigstore.dev"

    # ── Code hosts & container registries ─────────────────────
    "github.com"
    "githubusercontent.com"
    "githubcopilot.com"
    "gitlab.com"
    "bitbucket.org"
    "sourceforge.net"
    "launchpad.net"
    "docker.com"
    "docker.io"
    "dhi.io"
    "docker-images-prod.6aa30f8b08e16409b46e0173d6de2f56.r2.cloudflarestorage.com"
    "gcr.io"
    "ghcr.io"
    "quay.io"
    "public.ecr.aws"
    "mcr.microsoft.com"
    "k8s.io"

    # ── Cloud infra / CDNs / misc services ────────────────────
    "amazonaws.com"
    "azure.com"
    "dev.azure.com"
    "login.microsoftonline.com"
    "packages.microsoft.com"
    "visualstudio.com"
    "playwright.azureedge.net"
    "googleapis.com"
    "googleusercontent.com"
    "gstatic.com"
    "gvt1.com"
    "apis.google.com"
    "www.google.com"
    "play.google.com"
    "dl.google.com"
    "csp.withgoogle.com"
    "hashicorp.com"
    "fastly.com"
    "jsdelivr.net"
    "challenges.cloudflare.com"
    "clerk.com"
    "supabase.com"
    "vercel.com"
    "public.blob.vercel-storage.com"
    "figma.com"
    "binaries.prisma.sh"
    "app.daytona.io"
    "mise.run"
    "mise-versions.jdx.dev"
    "json-schema.org"
    "json.schemastore.org"

    # ── OS package repositories ───────────────────────────────
    "ubuntu.com"
    "debian.org"
    "alpinelinux.org"
    "archlinux.org"
    "fedoraproject.org"
    "centos.org"
    "apt.llvm.org"
    "packagecloud.io"

    # ── TLS cert validation (OCSP/CRL — many over HTTP:80) ─────
    "digicert.com"
    "globalsign.com"
    "globalsign.net"
    "sectigo.com"
    "comodoca.com"
    "usertrust.com"
    "identrust.com"
    "amazontrust.com"
    "lencr.org"
    "pki.goog"
    "pki.microsoft.com"
  ] (_: "*");
in
{
  inherit claude-jailed;
}
