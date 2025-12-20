{ ... }:
{
  nixosModule = {
    programs.niri.enable = true;
  };

  homeModule = { };
}
