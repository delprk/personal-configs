import XMonad
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- set terminal
myTerminal      = "kitty"

-- set if focus follows mouse
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- set whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- set window border width
myBorderWidth   = 1

-- set modmask
myModMask       = mod4Mask

-- set number of workspaces and workspace names
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- set border colors for unfocused and focused windows
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#5289eb"

------------------------------------------------------------------------
-- set binds
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")

    -- launch firefox
    , ((modm,               xK_f     ), spawn "firefox")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

    -- rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    -- reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], switch to workspace N
    -- mod-shift-[1..9], move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- set layouts:
myLayout = tiled ||| Mirror tiled ||| Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- the default number of windows in the master pane
     nmaster = 1

     -- default proportion of screen occupied by master pane
     ratio   = 1/2

     -- percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- window rules:

-- execute arbitrary actions and WindowSet manipulations when managing
-- a new window. you can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- to find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- to match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- defines a custom handler function for X Events. the function should
-- return (All True) if the default handler is to be run afterwards. to
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- status bars and logging

-- perform an arbitrary action on each internal state change or X event.
-- see the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- startup hook

-- perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- by default, do nothing.
myStartupHook = return ()

------------------------------------------------------------------------
-- now run xmonad with all the defaults we set up.

-- run xmonad with the settings you specify. No need to modify this.
--
main = xmonad defaults

-- a structure containing your configuration settings, overriding
-- fields in the default config. any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- no need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
