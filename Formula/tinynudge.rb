class Tinynudge < Formula
  desc "Tiny notifier for AI coding agents — banners + sound with click-to-focus"
  homepage "https://github.com/hiskuDN/tinynudge"
  version "1.1.1"

  on_arm do
    url "https://github.com/hiskuDN/tinynudge/releases/download/v1.1.1/tinynudge-arm64.tar.gz"
    sha256 "ab5d6ad97c5e2cce4e13335d27bb1129fae439e7543022f5a6ec708852c5bb3d"
  end

  on_intel do
    url "https://github.com/hiskuDN/tinynudge/releases/download/v1.1.1/tinynudge-x86_64.tar.gz"
    sha256 "dfd9b60765f8ccf5aa8b149ed6ebb36d59a7fb28e6fe4c799e352b3a948fe52b"
  end

  def install
    prefix.install "tinynudge.app"
    libexec.install "notify.sh"
  end

  def post_install
    install_dir = "#{Dir.home}/.tinynudge"
    notify_sh   = "#{install_dir}/notify.sh"

    # Install notify.sh
    system "mkdir", "-p", install_dir
    system "cp", "#{libexec}/notify.sh", notify_sh
    system "chmod", "+x", notify_sh

    # Wire Claude Code hooks
    if (Pathname.new(Dir.home)/".claude").directory?
      system "python3", "-c", <<~PY
        import json, os
        from pathlib import Path

        notify = os.path.expanduser("~/.tinynudge/notify.sh")
        path = Path(os.path.expanduser("~/.claude/settings.json"))
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
    end

    # Wire Cursor hooks
    if (Pathname.new(Dir.home)/".cursor").directory?
      system "python3", "-c", <<~PY
        import json, os
        from pathlib import Path

        notify = os.path.expanduser("~/.tinynudge/notify.sh")
        path = Path(os.path.expanduser("~/.cursor/hooks.json"))
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
    end
  end

  def caveats
    <<~EOS
      tinynudge hooks have been wired for any detected agents (Claude Code, Cursor).

      To add support for more agents or re-run setup:
        git clone https://github.com/hiskuDN/tinynudge.git && cd tinynudge && ./install.sh

      Optional — focus your editor automatically on notification (no click needed):
        export TINYNUDGE_ACTIVATE_IMMEDIATELY=true

      To uninstall hooks: run uninstall.sh from the repo, or brew uninstall tinynudge.
    EOS
  end

  test do
    assert_predicate prefix/"tinynudge.app/Contents/MacOS/tinynudge", :executable?
    assert_predicate libexec/"notify.sh", :executable?
  end
end
