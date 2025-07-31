# Firefox userChrome.css theme
# Simplified theme using color variable template
{...}: let
  colorscheme = import ../../../lib/colorscheme.nix;
in {
  # Simplified userChrome.css using Mozilla's color variable template
  userChromeCSS = ''
    /* Source file https://github.com/MrOtherGuy/firefox-csshacks/tree/master/chrome/color_variable_template.css made available under Mozilla Public License v. 2.0
    See the above repository for updates as well as full license text. */

    /* You should enable any non-default theme for these to apply properly. Built-in dark and light themes should work */
    :root{
      /* Popup panels */
      --arrowpanel-background: ${colorscheme.palette.darkPurple} !important;
      --arrowpanel-border-color: ${colorscheme.palette.midPurple} !important;
      --arrowpanel-color: ${colorscheme.palette.white} !important;
      --arrowpanel-dimmed: rgba(0,0,0,0.4) !important;
      /* window and toolbar background */
      --lwt-accent-color: ${colorscheme.palette.black} !important;
      --lwt-accent-color-inactive: ${colorscheme.palette.darkPurple} !important;
      --toolbar-bgcolor: rgba(0,0,0,0.4) !important;
      --tabpanel-background-color: ${colorscheme.palette.darkPurple} !important;
      /* tabs with system theme - text is not controlled by variable */
      --tab-selected-bgcolor: ${colorscheme.palette.midPurple} !important;
      /* tabs with any other theme */
      --lwt-text-color: ${colorscheme.palette.white} !important;
      --lwt-selected-tab-background-color: ${colorscheme.palette.midPurple} !important;
      /* toolbar area */
      --toolbarbutton-icon-fill: ${colorscheme.palette.white} !important;
      --lwt-toolbarbutton-hover-background: ${colorscheme.palette.lightPurple} !important;
      --lwt-toolbarbutton-active-background: ${colorscheme.palette.pink} !important;
      /* urlbar */
      --toolbar-field-border-color: ${colorscheme.palette.black} !important;
      --toolbar-field-focus-border-color: ${colorscheme.palette.pink} !important;
      --urlbar-popup-url-color: ${colorscheme.palette.cyan} !important;
      /* urlbar Firefox < 92 */
      --lwt-toolbar-field-background-color: ${colorscheme.palette.darkPurple} !important;
      --lwt-toolbar-field-focus: ${colorscheme.palette.midPurple} !important;
      --lwt-toolbar-field-color: ${colorscheme.palette.white} !important;
      --lwt-toolbar-field-focus-color: ${colorscheme.palette.white} !important;
      /* urlbar Firefox 92+ */
      --toolbar-field-background-color: ${colorscheme.palette.black} !important;
      --toolbar-field-focus-background-color: ${colorscheme.palette.midPurple} !important;
      --toolbar-field-color: ${colorscheme.palette.white} !important;
      --toolbar-field-focus-color: ${colorscheme.palette.white} !important;
      /* sidebar - note the sidebar-box rule for the header-area */
      --lwt-sidebar-background-color: ${colorscheme.palette.black} !important;
      --lwt-sidebar-text-color: ${colorscheme.palette.white} !important;
    }
    /* line between nav-bar and tabs toolbar,
        also fallback color for border around selected tab */
    #navigator-toolbox{ --lwt-tabs-border-color: ${colorscheme.palette.midPurple} !important; }
    /* Line above tabs */
    #tabbrowser-tabs{ --lwt-tab-line-color: ${colorscheme.palette.white} !important; }
    /* the header-area of sidebar needs this to work */
    #sidebar-box{ --sidebar-background-color: ${colorscheme.palette.black} !important; }

    /* Main navigation toolbar */
    #nav-bar {
      background-color: ${colorscheme.palette.black} !important;
    }

    /* Tab bar background for both horizontal and vertical tabs */
    #TabsToolbar, .toolbar-items {
      background-color: ${colorscheme.palette.black} !important;
    }

    /* Title bar background - comprehensive selectors */
    #titlebar, #navigator-toolbox-background, .titlebar-buttonbox-container {
      background-color: ${colorscheme.palette.black} !important;
    }

    /* Vertical tabs container and footer */
    #vertical-tabs, .tabbrowser-arrowscrollbox, #sidebar-main {
      background-color: ${colorscheme.palette.black} !important;
    }

    /* Context menus and popups */
    #PersonalToolbar menupopup,
    #mainPopupSet menupopup,
    #toolbar-menubar menupopup,
    #placesContext,
    #urlbar-input-container menupopup,
    #back-button menupopup, #forward-button menupopup,
    #identity-popup, #appMenu-popup, #downloadsPanel, #BMB_bookmarksPopup {
      --menu-color: ${colorscheme.palette.white} !important;
      --arrowpanel-color: ${colorscheme.palette.white} !important;
      --panel-color: ${colorscheme.palette.white} !important;
      --menu-background-color: ${colorscheme.palette.darkPurple} !important;
      --arrowpanel-background: ${colorscheme.palette.darkPurple} !important;
      --panel-background: ${colorscheme.palette.darkPurple} !important;
      --menu-border-color: ${colorscheme.palette.midPurple} !important;
      --arrowpanel-border-color: ${colorscheme.palette.midPurple} !important;
      --panel-border-color: ${colorscheme.palette.midPurple} !important;
      --menuitem-hover-background-color: ${colorscheme.palette.lightPurple} !important;
      --button-hover-bgcolor: ${colorscheme.palette.lightPurple} !important;
      --menu-disabled-color: rgba(255, 255, 255, 0.4) !important;
      --menuitem-disabled-hover-background-color: rgba(255, 255, 255, 0.1) !important;
    }
  '';
}
