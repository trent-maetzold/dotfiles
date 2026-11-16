# XFCE on X11, laid out like Windows: one bottom taskbar with a start menu,
# icon-only task buttons, tray and clock. Fluent theme, Papirus icons.
# These are first-login defaults (/etc/xdg); users' own changes win.
{pkgs, ...}: let
  theme = "Fluent-Light";
  icons = "Papirus";
in {
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.greeters.gtk = {
      theme = {
        name = theme;
        package = pkgs.fluent-gtk-theme;
      };
      iconTheme = {
        name = icons;
        package = pkgs.papirus-icon-theme;
      };
    };
  };
  services.displayManager.defaultSession = "xfce";
  programs.nm-applet.enable = true;
  # NixOS turns libinput's disable-while-typing off on X11; palms while typing.
  services.libinput.touchpad.disableWhileTyping = true;

  environment.systemPackages = with pkgs; [
    fluent-gtk-theme
    papirus-icon-theme
    xfce4-whiskermenu-plugin
    xfce4-pulseaudio-plugin
    pavucontrol
  ];

  environment.etc = {
    "xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xsettings" version="1.0">
        <property name="Net" type="empty">
          <property name="ThemeName" type="string" value="${theme}"/>
          <property name="IconThemeName" type="string" value="${icons}"/>
        </property>
        <property name="Gtk" type="empty">
          <property name="FontName" type="string" value="Noto Sans 10"/>
          <property name="MonospaceFontName" type="string" value="Noto Sans Mono 10"/>
        </property>
        <property name="Xft" type="empty">
          <property name="Antialias" type="int" value="1"/>
          <property name="Hinting" type="int" value="1"/>
          <property name="HintStyle" type="string" value="hintslight"/>
          <property name="RGBA" type="string" value="rgb"/>
        </property>
      </channel>
    '';
    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfwm4" version="1.0">
        <property name="general" type="empty">
          <property name="theme" type="string" value="${theme}"/>
          <property name="title_font" type="string" value="Noto Sans Bold 10"/>
          <property name="button_layout" type="string" value="O|HMC"/>
          <property name="workspace_count" type="int" value="1"/>
        </property>
      </channel>
    '';
    # Blank after 5 min idle, lock 5 min later; screen off at 15 (AC) / 10
    # (battery) min, sleep at 30 / 15. Lock on wake; shut down at 10% battery.
    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfce4-screensaver" version="1.0">
        <property name="saver" type="empty">
          <property name="enabled" type="bool" value="true"/>
          <property name="mode" type="int" value="0"/>
          <property name="idle-activation" type="empty">
            <property name="enabled" type="bool" value="true"/>
            <property name="delay" type="int" value="5"/>
          </property>
        </property>
        <property name="lock" type="empty">
          <property name="enabled" type="bool" value="true"/>
          <property name="saver-activation" type="empty">
            <property name="enabled" type="bool" value="true"/>
            <property name="delay" type="int" value="5"/>
          </property>
          <property name="sleep-activation" type="bool" value="true"/>
        </property>
      </channel>
    '';
    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfce4-power-manager" version="1.0">
        <property name="xfce4-power-manager" type="empty">
          <property name="dpms-enabled" type="bool" value="true"/>
          <property name="dpms-on-ac-sleep" type="uint" value="0"/>
          <property name="dpms-on-ac-off" type="uint" value="15"/>
          <property name="dpms-on-battery-sleep" type="uint" value="0"/>
          <property name="dpms-on-battery-off" type="uint" value="10"/>
          <property name="inactivity-on-ac" type="uint" value="30"/>
          <property name="inactivity-on-battery" type="uint" value="15"/>
          <property name="inactivity-sleep-mode-on-ac" type="uint" value="1"/>
          <property name="inactivity-sleep-mode-on-battery" type="uint" value="1"/>
          <property name="lock-screen-suspend-hibernate" type="bool" value="true"/>
          <property name="critical-power-level" type="uint" value="10"/>
          <property name="critical-power-action" type="uint" value="4"/>
        </property>
      </channel>
    '';
    "xdg/xfce4/panel/default.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfce4-panel" version="1.0">
        <property name="configver" type="int" value="2"/>
        <property name="panels" type="array">
          <value type="int" value="1"/>
          <property name="dark-mode" type="bool" value="false"/>
          <property name="panel-1" type="empty">
            <property name="position" type="string" value="p=8;x=0;y=0"/>
            <property name="length" type="uint" value="100"/>
            <property name="position-locked" type="bool" value="true"/>
            <property name="size" type="uint" value="40"/>
            <property name="icon-size" type="uint" value="0"/>
            <property name="plugin-ids" type="array">
              <value type="int" value="1"/>
              <value type="int" value="2"/>
              <value type="int" value="3"/>
              <value type="int" value="4"/>
              <value type="int" value="5"/>
              <value type="int" value="6"/>
              <value type="int" value="7"/>
            </property>
          </property>
        </property>
        <property name="plugins" type="empty">
          <property name="plugin-1" type="string" value="whiskermenu"/>
          <property name="plugin-2" type="string" value="tasklist">
            <property name="grouping" type="uint" value="1"/>
            <property name="show-labels" type="bool" value="false"/>
            <property name="flat-buttons" type="bool" value="true"/>
          </property>
          <property name="plugin-3" type="string" value="separator">
            <property name="expand" type="bool" value="true"/>
            <property name="style" type="uint" value="0"/>
          </property>
          <property name="plugin-4" type="string" value="systray">
            <property name="square-icons" type="bool" value="true"/>
          </property>
          <property name="plugin-5" type="string" value="pulseaudio"/>
          <property name="plugin-6" type="string" value="clock"/>
          <property name="plugin-7" type="string" value="showdesktop"/>
        </property>
      </channel>
    '';
  };
}
