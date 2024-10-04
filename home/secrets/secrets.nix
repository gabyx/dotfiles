# This file is not part of the NixOS configuration and
# is only used for `agenix -e` which encrypts secrets over `age`
# with these public keys.
# For example `user` is a normal public key from `age`. The documentation of `agenix`
# uses an SSH keys e.g. `ssh-ed25519 ...` which also work with `age`.
#
# Unfortunately, `agenix` needs the private key not passphrase-protected
# e.g a file `private-key` and
# not `private-key.age`,
# the same goes for private SSH key which must not be passphrase protected,
# this is due to the systemd `agenix.service` which decryptes the secrets during
# activation of the NixOS.
# There is the need to hijack or modify the pinentry prompt in `age` to reroute it to
# the system keyring (gnome-keyring) or a running `ssh-agent` or better `age-agent`.
# We are not going to use non-passphrase protected private-key files because that is
# just a no-go.
let
  user = "age1l2ych6z5kzdthuh7vu58jfcps0axrhfflvmk0978jkka6clg39fsl98t08";
in
{
  # The name `secret1` corresponds to a corresponding `age.secrets.secret1.file` entry
  # somewhere in the NixOS configuration which defines encrypted file.
  "secret1.age".publicKeys = [ user ];
}
