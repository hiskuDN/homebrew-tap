class Tinynudge < Formula
  desc "Tiny notifier for AI coding agents — banners + sound with click-to-focus"
  homepage "https://github.com/hiskuDN/tinynudge"
  version "1.1.3"

  on_arm do
    url "https://github.com/hiskuDN/tinynudge/releases/download/v1.1.3/tinynudge-arm64.tar.gz"
    sha256 "446ab4d46541161a69a21098f20a246b3be7a852d2e064d206ffc0076339a1bf"
  end

  on_intel do
    url "https://github.com/hiskuDN/tinynudge/releases/download/v1.1.3/tinynudge-x86_64.tar.gz"
    sha256 "356509536a062cbabfc567281ee6b50a33066d81942abfaa8fcf81c19fb3a4fa"
  end

  def install
    prefix.install "tinynudge.app"
    libexec.install "notify.sh"

    # Generate tinynudge-setup command with the correct libexec path baked in
    (bin/"tinynudge-setup").write <<~SH
      #!/usr/bin/env bash
      # Wire tinynudge hooks for detected agents (Claude Code, Cursor)
      set -e

      NOTIFY_SRC="#{libexec}/notify.sh"
      INSTALL_DIR="$HOME/.tinynudge"
      NOTIFY="$INSTALL_DIR/notify.sh"

      echo "Setting up tinynudge..."
      mkdir -p "$INSTALL_DIR"
      cp "$NOTIFY_SRC" "$NOTIFY"
      chmod +x "$NOTIFY"
      echo "  Installed notify.sh -> $NOTIFY"

      # Claude Code
      if [[ -d "$HOME/.claude" ]]; then
        python3 - "$HOME/.claude/settings.json" "$NOTIFY" <<'PY'
      import json, os, sys
      from pathlib import Path

      path = Path(sys.argv[1])
      notify = sys.argv[2]
      path.parent.mkdir(parents=True, exist_ok=True)
      settings = json.loads(path.read_text() or "{}") if path.exists() else {}

      hooks = settings.setdefault("hooks", {})
      for event, arg in [("Stop", "stop"), ("PermissionRequest", "permission")]:
          groups = hooks.setdefault(event, [])
          cmd = f"{notify} claude-code {arg}"
          if not any(
              any(h.get("command") == cmd for h in g.get("hooks", []))
              for g in groups
          ):
              groups.append({"matcher": "", "hooks": [{"type": "command", "command": cmd}]})

      path.write_text(json.dumps(settings, indent=2) + "\\n")
      print(f"  Wired Claude Code hooks -> {path}")
      PY
      fi

      # Cursor
      if [[ -d "$HOME/.cursor" ]]; then
        python3 - "$HOME/.cursor/hooks.json" "$NOTIFY" <<'PY'
      import json, os, sys
      from pathlib import Path

      path = Path(sys.argv[1])
      notify = sys.argv[2]
      path.parent.mkdir(parents=True, exist_ok=True)
      settings = json.loads(path.read_text()) if path.exists() else {}

      hooks = settings.setdefault("hooks", {})
      stop_cmd = f"{notify} cursor stop"
      stop = hooks.setdefault("stop", [])
      if not any(h.get("command") == stop_cmd for h in stop):
          stop.append({"type": "command", "command": stop_cmd})

      path.write_text(json.dumps(settings, indent=2) + "\\n")
      print(f"  Wired Cursor hooks -> {path}")
      PY
      fi

      echo ""
      echo "Done! Set TINYNUDGE_ACTIVATE_IMMEDIATELY=true to focus without clicking."
    SH
    chmod "+x", bin/"tinynudge-setup"
  end

  def caveats
    <<~EOS
      Run the setup command to wire hooks for your agents (Claude Code, Cursor):

        tinynudge-setup

      Optional — focus your editor automatically on notification (no click needed):
        export TINYNUDGE_ACTIVATE_IMMEDIATELY=true
    EOS
  end

  test do
    assert_predicate prefix/"tinynudge.app/Contents/MacOS/tinynudge", :executable?
    assert_predicate libexec/"notify.sh", :executable?
    assert_predicate bin/"tinynudge-setup", :executable?
  end
end
