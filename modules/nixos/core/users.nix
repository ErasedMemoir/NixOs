# Users and sudo.
{
  users = {
    mutableUsers = false;

    users.erased = {
      uid = 1000;
      isNormalUser = true;
      description = "Erased";
      extraGroups = [ "wheel" ];

      # Without this file the account is locked, see README.
      hashedPasswordFile = "/data/secrets/erased.hash";
    };
  };

  security.sudo.extraConfig = "Defaults lecture=never,pwfeedback";
}
