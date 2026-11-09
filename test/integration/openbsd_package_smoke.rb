# A non-destructive check of the actual OpenBSD package and filesystem APIs.
test_name 'OpenBSD package tools and temporary filesystem' do
  host = hosts.first

  step 'Confirm the native OpenBSD package tools and installed database work' do
    on(host, 'command -v pkg_info && command -v pkg_add && command -v pkg_delete')
    on(host, 'pkg_info -a >/dev/null')
  end

  step 'Confirm remote shell and writable temporary filesystem' do
    on(host, 'test -x /bin/sh && test -d /tmp')
    on(host, 'f=$(mktemp /tmp/beaker-openbsd.XXXXXX) && ' \
             'printf test > "$f" && test "$(cat "$f")" = test && rm -f "$f"')
  end
end
