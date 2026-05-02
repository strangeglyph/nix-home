{
  ...
}:
{
  config = {
    security.pam.services = {
      su.requireWheel = true;
      su-l.requireWheel = true;
      system-login.failDelay.delay = 2000000; # 2 seconds
    };
  };
}
