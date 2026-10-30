# polkit, keyring and PAM.
{
  security = {
    polkit.enable = true;

    pam.services = {
      greetd.enableGnomeKeyring = true;

      swaylock = { };
    };
  };

  services.gnome.gnome-keyring.enable = true;
}
