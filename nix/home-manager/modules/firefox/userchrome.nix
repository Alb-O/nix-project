# Firefox userChrome.css theme
# Custom UI theming using our colorscheme
{...}: let
  colorscheme = import ../../../lib/colorscheme.nix;
in {
  # Custom userChrome.css template using our colorscheme
  userChromeCSS = ''
    /* Firefox UI Theme - Purple Colorscheme */
    /* Compatible with vertical tabs setup */

    @-moz-document url(chrome://browser/content/browser.xul), url(chrome://browser/content/browser.xhtml) {

      /* Root color variables */
      :root {
        --purple-bg: ${colorscheme.palette.black};
        --purple-bg-light: ${colorscheme.palette.darkPurple};
        --purple-surface: ${colorscheme.palette.midPurple};
        --purple-accent: ${colorscheme.palette.pink};
        --purple-accent-light: ${colorscheme.palette.lightPurple};
        --purple-text: ${colorscheme.palette.white};
        --purple-text-dim: ${colorscheme.palette.lightGray};
        --purple-border: ${colorscheme.palette.midPurple};
        --purple-hover: ${colorscheme.palette.lightPurple}40;
        --purple-active: ${colorscheme.palette.pink}60;
      }

      /* Main browser window background */
      #main-window {
        background-color: var(--purple-bg) !important;
      }

      /* Tab bar (hidden for vertical tabs but styled for consistency) */
      #TabsToolbar {
        background-color: var(--purple-bg) !important;
        border-bottom: 1px solid var(--purple-border) !important;
      }

      /* Navigation bar styling */
      #nav-bar {
        background: var(--purple-bg-light) !important;
        border-bottom: 1px solid var(--purple-border) !important;
        box-shadow: none !important;
      }

      /* URL bar styling */
      #urlbar {
        background-color: var(--purple-surface) !important;
        border: 1px solid var(--purple-border) !important;
        border-radius: 8px !important;
        color: var(--purple-text) !important;
      }

      #urlbar:hover {
        border-color: var(--purple-accent-light) !important;
        box-shadow: 0 0 0 1px var(--purple-accent-light)40 !important;
      }

      #urlbar[focused="true"] {
        background-color: var(--purple-bg-light) !important;
        border-color: var(--purple-accent) !important;
        box-shadow: 0 0 0 2px var(--purple-accent)60 !important;
      }

      /* URL bar text */
      #urlbar-input {
        color: var(--purple-text) !important;
      }

      /* URL bar placeholder */
      #urlbar-input::placeholder {
        color: var(--purple-text-dim) !important;
        opacity: 0.7 !important;
      }

      /* Buttons in nav bar */
      #nav-bar toolbarbutton {
        border-radius: 6px !important;
      }

      #nav-bar toolbarbutton:hover {
        background-color: var(--purple-hover) !important;
      }

      #nav-bar toolbarbutton:active {
        background-color: var(--purple-active) !important;
      }

      /* Back/forward buttons */
      #back-button, #forward-button {
        border: none !important;
      }

      /* Reload/stop button */
      #reload-button, #stop-button {
        border: none !important;
      }

      /* Menu button */
      #PanelUI-menu-button {
        border-radius: 6px !important;
      }

      #PanelUI-menu-button:hover {
        background-color: var(--purple-hover) !important;
      }

      /* Sidebar styling (for vertical tabs) */
      #sidebar-box {
        background-color: var(--purple-bg) !important;
        border-right: 1px solid var(--purple-border) !important;
      }

      #sidebar-header {
        background-color: var(--purple-bg-light) !important;
        border-bottom: 1px solid var(--purple-border) !important;
        color: var(--purple-text) !important;
      }

      /* Content area */
      #browser {
        background-color: var(--purple-bg) !important;
      }

      /* Toolbar customization area */
      #navigator-toolbox {
        background-color: var(--purple-bg) !important;
      }

      /* Bookmarks toolbar */
      #PersonalToolbar {
        background-color: var(--purple-bg-light) !important;
        border-bottom: 1px solid var(--purple-border) !important;
      }

      .bookmark-item {
        color: var(--purple-text) !important;
        border-radius: 4px !important;
      }

      .bookmark-item:hover {
        background-color: var(--purple-hover) !important;
      }

      /* Context menus and panels */
      menupopup, panel, .panel-arrowcontainer, .panel-arrowcontent {
        background-color: var(--purple-bg-light) !important;
        border: 1px solid var(--purple-border) !important;
        border-radius: 8px !important;
        color: var(--purple-text) !important;
      }

      /* Menu items */
      menuitem, .subviewbutton, .panel-subview-body {
        background-color: var(--purple-bg-light) !important;
        color: var(--purple-text) !important;
      }

      menuitem:hover, .subviewbutton:hover {
        background-color: var(--purple-surface) !important;
        color: var(--purple-text) !important;
      }

      /* Dropdown menus */
      .menupopup-arrowscrollbox, .popup-internal-box {
        background-color: var(--purple-bg-light) !important;
      }

      /* URL bar dropdown */
      .urlbarView, .search-one-offs {
        background-color: var(--purple-bg-light) !important;
        color: var(--purple-text) !important;
      }

      .urlbarView-row {
        background-color: var(--purple-bg-light) !important;
        color: var(--purple-text) !important;
      }

      .urlbarView-row[selected] {
        background-color: var(--purple-surface) !important;
      }

      /* Scrollbars */
      scrollbar {
        background-color: var(--purple-bg) !important;
      }

      scrollbar thumb {
        background-color: var(--purple-surface) !important;
        border-radius: 10px !important;
      }

      scrollbar thumb:hover {
        background-color: var(--purple-accent-light) !important;
      }

      /* Status panel (link previews) */
      #statuspanel {
        background-color: var(--purple-bg-light) !important;
        border: 1px solid var(--purple-border) !important;
        border-radius: 6px !important;
        color: var(--purple-text) !important;
      }

      /* Findbar */
      .findbar-textbox {
        background-color: var(--purple-surface) !important;
        border: 1px solid var(--purple-border) !important;
        color: var(--purple-text) !important;
      }

      /* Notification bars */
      .notificationbox-stack > notification {
        background-color: var(--purple-bg-light) !important;
        border-bottom: 1px solid var(--purple-border) !important;
        color: var(--purple-text) !important;
      }

      /* Loading page / blank page background */
      #tabbrowser-tabpanels, .browserContainer, .browserStack {
        background-color: var(--purple-bg) !important;
      }

      /* About:blank and loading pages */
      browser[type="content-primary"], browser[type="content"] {
        background-color: var(--purple-bg) !important;
      }

      /* Tab content area */
      .tab-content {
        background-color: var(--purple-bg) !important;
      }
    }
  '';
}
