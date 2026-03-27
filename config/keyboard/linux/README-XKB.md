# German: Explanations for XKB

[Read here](docs/own-keyboard-in-x11-german.html).

# English: A simple, humble but comprehensive guide to XKB for linux

[Read here](./docs/a-simple-humble-but-comprehensive-guide-to-xkb-for-linux.html).

or here as markdown

> medium-to-markdown@0.0.3 convert node index.js
> <https://medium.com/@damko/a-simple-humble-but-comprehensive-guide-to-xkb-for-linux-6f1ad5e13450>

- Are you a linux user?
- Would you like to remap some keys of your keyboard? (any keyboard)
- Would you like to quickly switch between different keyboard layouts?
- Are you “serverfault-fed” whenever you need to touch your keyboard layout?
- Are you chocking under the zillion of different solutions Google have found
  for your remapping issue but none of them seems to work?
- Would you like to write a custom layout for your Kinesis or Ergodox keyboard?

If you answered _yes_ to some of my questions then this article is definitely
for you. I’m not a guru but I’m here to share what I’ve learned so far.

## Under the hood

Linux, during the booting process, goes through several stages called _init_ and
they are numbered from 1 to 5.

You can picture those stages as NASA missile stages:

Each init launches the next one and enables new features like file system
decryption, users support, network support, network services …

_Init 5_ is the point where you see the graphical environment, usually
displaying the login window. _Init 3_ is the place where, among many other
things, the X service is loaded. The X service is responsible for providing the
basic _Graphical User Interface_ which is then completed and managed by the
_Windows Manager_ (Gnome, Kde, Xfce, I3 …)

The X service is tightly coupled with [XKB](https://www.x.org/wiki/XKB/) the
software responsible for handling your keyboard settings and layouts.

/etc/X11/xorg.conf is the configuration file for the X service in which it’s
possible to set some configuration settings for XKB in this way:

```
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "cz,us"
        Option "XkbModel" "pc104"
        Option "XkbVariant" ",dvorak"
        Option "XkbOptions" "grp:alt\_shift\_toggle"
EndSection
```

You will find millions of this examples on the internet but look at my /etc/X11
directory on Linux Mint 17.1

```
$ tree
.
├── app-defaults
│   ├── Bitmap
│   ├── Bitmap-color
│   ├── Bitmap-nocase
│   ├── Clock-color
│   ├── Editres
│   ├── Editres-color
│   ├── Viewres
│   ├── Viewres-color
│   ├── XCalc
│   ├── XCalc-color
│   ├── XClipboard
│   ├── XClock
│   ├── XClock-color
│   ├── XConsole
│   ├── Xditview
│   ├── Xditview-chrtr
│   ├── Xedit
│   ├── Xedit-color
│   ├── Xfd
│   ├── XFontSel
│   ├── Xgc
│   ├── Xgc-color
│   ├── XLoad
│   ├── XLogo
│   ├── XLogo-color
│   ├── Xmag
│   ├── Xman
│   ├── Xmessage
│   ├── Xmessage-color
│   ├── XMore
│   ├── XSm
│   └── Xvidtune
├── default-display-manager
├── fonts
│   ├── misc
│   │   └── xfonts-base.alias
│   └── Type1
│       ├── gsfonts-x11.alias
│       ├── gsfonts-x11.scale
│       ├── xfonts-mathml.scale
│       └── xfonts-scalable.scale
├── rgb.txt
├── X -> /usr/bin/Xorg
├── xinit
│   ├── xinitrc
│   ├── xinputrc
│   └── xserverrc
├── xkb
├── Xreset
├── Xreset.d
│   └── README
├── Xresources
│   └── x11-common
├── Xsession
├── Xsession.d
│   ├── 00upstart
│   ├── 20x11-common\_process-args
│   ├── 30x11-common\_xresources
│   ├── 35x11-common\_xhost-local
│   ├── 40x11-common\_xsessionrc
│   ├── 50\_check\_unity\_support
│   ├── 50x11-common\_determine-startup
│   ├── 55cinnamon-session\_gnomerc
│   ├── 60x11-common\_localhost
│   ├── 60x11-common\_xdg\_path
│   ├── 60xdg-user-dirs-update
│   ├── 70gconfd\_path-on-session
│   ├── 70im-config\_launch
│   ├── 75dbus\_dbus-launch
│   ├── 90consolekit
│   ├── 90gpg-agent
│   ├── 90qt-a11y
│   ├── 90x11-common\_ssh-agent
│   ├── 98vboxadd-xclient
│   ├── 99upstart
│   └── 99x11-common\_start
├── Xsession.options
├── xsm
│   └── system.xsm
└── Xwrapper.config
```

There is no xorg.conf and no trace, in the whole X11 directory, of any XKB
option. This is because most of the recent distributions don’t use it anymore. I
assume they make it on the fly accordingly to _xrandr_ output but I might be
wrong.

You, old school, can surely write your own xorg.conf and write there your XKB
settings, but I don’t see any good reason to do so if X is working. I know by
experience how hard and frustrating it can be writing a good _xorg.conf_ file,
especially when there is complicated monitor setup.

Anyway, good news: there is no need to write your own xorg.conf.

## Where does the “magic” happen?

In two places:

- _/etc/default/keyboard_
- _/usr/share/x11/xkb_

This is my _/etc/default/keyboard_

```
XKBMODEL="kinesis"
XKBLAYOUT="us,us"
XKBVARIANT="kinesis\_adv\_dvorak\_it,rus"
XKBOPTIONS="caps:none,shift:both\_capslock,lv3:rwin\_switch,grp:alt\_space\_toggle"
#XKBOPTIONS="terminate:ctrl\_alt\_bksp"
```

This is where the X service looks for the options to pass to XKB. Don’t get lost
right now, keep reading. I’ll come back to this later.

The directory /usr/share/X11/xkb hosts the configuration files for XKB :

```
$ cd /usr/share/X11/xkb
$ tree -L 2
.
├── compat
├── geometry
├── keycodes
├── LICENSE
├── README.md
├── rules
├── symbols
└── types
```

Your windows manager uses the information stored there to populate the options
of their own keyboard-manager application.

Cinnamon’s (the windows manager I sometimes use in Linux Mint) keyboard-manager
application can be launched with the command :

_cinnamon-settings keyboard_

When you click the + button to add a new layout, the shown list of layouts comes
from parsing the configuration files stored in _/usr/share/X11/xkb/_

## Some terminology

Before going ahead let’s get clear on some terms:

**home row**: the central row of your keyboard where you place your fingers
before typing.

**keyboard layout**: it’s your set of keys on the keyboard and how they are
arranged. QWERTY is a layout, the most common. The name comes from reading the
first six keys appearing on the top left letter row of the keyboard.

DVORAK is a layout: the name comes from its inventor. Its main feature is to
have all the vowels placed on the left of the home row and it’s meant to speed
up your typing rate and reduce the stress on your fingers.

There are many other layouts like this ([colemak](https://colemak.com/), for
instance) and I would call them _macro-layout_ because for each macro-layout
there are plenty of layout variants. And you can add yours.

**layout variant:** it represents the changes made to a “macro-layout” to adjust
it to a different language. English and Russian have a quite a different
charset: one is Latin the other one Cyrillic. English and Italian have a the
same Latin charset but (modern) English lacks some diacritics (accents) that are
still present in Italian.

QWERTY US layoutQWERTY Italian layoutDVORAK US layout

Each language has its own layout and of course, a user might want a customized
layout. Aren’t we all here for this?

**key mapping:**when you press a key on the keyboard, the operating system gets
a key-code. Which is a number. You can see this by using the _xev_ program
included in the _x11-utils_ package. From a terminal launch “_xev -event
keyboard”_ to see it in action. For instance by hit «a» you will see:

```
**KeyPress** event, serial 28, synthetic NO, window 0x2a00001,
    root 0x29a, subw 0x0, time 88951134, (191,-3), root:(195,993),
    state 0x0, **keycode 38** (keysym 0x61, a), same\_screen YES,
    XLookupString gives 1 bytes: (61) "a"
    XmbLookupString gives 1 bytes: (61) "a"
    XFilterEvent returns: False**KeyRelease** event, serial 28, synthetic NO, window 0x2a00001,
    root 0x29a, subw 0x0, time 88951326, (191,-3), root:(195,993),
    state 0x0, **keycode 38** (keysym 0x61, a), same\_screen YES,
    XLookupString gives 1 bytes: (61) "a"
    XFilterEvent returns: False
```

38 is the key-code for the «a» letter.

**modifier keys**: as you can see from the previous experience, the operating
system is informed of two events: when the key is pressed and when it’s
released. If you keep holding the key you will see those two blocks repeating
quite fast. This does not happen with the so called _modifier keys_ like «CTRL»,
«SHIFT», «ALT», «ALT_GR», «ESC», «CAPS LOCK«, «INSERT», «NUM LOCK» etc. All the
keys look alike but they are not
([it’s not what it looks like](https://bigbangtrans.wordpress.com/series-5-episode-01-the-skank-reflex-analysis/)
:-)). Some are special.

Modifiers are used to perform alterations on regular characters:

- with the SHIFT you can temporary make a capital letter
- with the CAPS LOCK you make just capital letters
- with the «3rd level modifier» (an arbitrary key chosen among the modifiers
  set, usually the «ALT GR» or the «Windows key») you have access to the letters
  written on the top and bottom right of some keys of your keyboard. Have a look
  at the Italian QWERTY layout: see the «\[» character? that’s «3rd level
  modifier» + «è» see the «{» character? that’s «3rd level modifier» + «SHIFT» +
  «è»

## The configuration directory

The configuration files contained in _/usr/share/X11/xkb_ can be divided in 3
groups accordingly to their aim:

1. files to graphically display the keyboard layout
2. files to configure the key mapping and the keyboard layout
3. files to enable the configuration

```
├── geometry      # this is group 1├── keycodes      # this is group 2

├── rules         # this is group 3├── symbols       # this is group 2
```

> I have no clear idea what’s the role of the \_compat and types directorie_s
> but I never had the need to touch them.

**Group 1**: In the _geometry_ directory there are files giving instruction to
the keyboard-manager application about the physical appearance of the keyboard.
For the fun of it, I adjusted a geometry file found on the internet for my
[Kinesis Advantage](http://www.kinesis-ergo.com/shop/advantage-for-pc-mac/). Now
when I click on the keyboard icon of the keyboard-manager application I see
this:

Kinesis geometry for Gnome — Cinnamon

**Group 2:** In the _keycodes_ and _symbols_ directories there are files to
modify to design a custom layout.

In the _keycodes/evdev_ file you can map a binding between the key-code and the
key-symbol. The key-symbol will be interpreted by XKB accordingly to the mapping
table written in the file _symbols/us._

Let me show you better.

This is a chunk from _keycodes/evdev :_

```
 <TLDE> = 49;
 <BKSP> = 22;
```

It’s binding:

- the key-code 49 to the TLDE (tilde «~») symbol
- the key-code 22 to the BKSP (backspace) symbol

This is a chunk from _symbols/us_

```
key <TLDE> { \[ grave, asciitilde \] };
key <BKSP> { \[ BackSpace, BackSpace \] };\[
```

It’s binding:

- the TLDE symbol to 2 characters: «\`» and «~».
- the BKSP symbol to «Backspace» and «Backspace»

The latter of the 2 characters is always triggered with the combination
«SHIFT» + KEY. This means that BACKSPACE works as BACKSPACE even if the SHIFT is
pressed. It’s invariant, try it. The _symbols/us_ file hosts many different
layouts. Each layout can be written from scratch or it can inherit from a parent
layout and modify something.

Ex.:

I named this layout variant _kinesis_adv_dvorak_it_custom._ In cinnamon-settings
it will be displayed as _Kinesis Advantage (Dvorak US Custom)_ and it includes a
parent layout variant named _us(kinesis_adv_dvorak_it)_ which is, again, child
of the _us_ layout. And it performs no modification to the parent behavior.

```
xkb\_symbols "kinesis\_adv\_dvorak\_it\_custom" {
 name\[Group1\] = "Kinesis Advantage (Dvorak US Custom)";
 include "us(kinesis\_adv\_dvorak\_it)"
 // add here below whatever customization you like
};
```

**Group 3:** The files contained in the _rules_ directory inform XKB about the
available layouts and their children (layout-variants).

These are:

- base.lst
- base.xml
- evdev.lst
- evdev.xml

base.lst and evdev.lst are identical, same as base.xml and evdev.xml. I don’t
know yet why they are identical and why they are not symlinks.

Anyway let’s focus on the QWERTY US layout: in base.lst, look for “English (US)”
and you will see these lines of which the first one is introducing the layout
identifier “**us”**:

```
! layout
  **us**              English (US)
...
...
! variant
  chr             **us**: Cherokee
```

in base.xml, look for “English (US)” and you will see these lines:

```
<layoutList>
    <**layout**\>
      <configItem>
        <name>us</name>
        <shortDescription>en</shortDescription>
        <description>**English (US)**</description>
        <languageList>
          <iso639Id>eng</iso639Id>
        </languageList>
      </configItem>
      <variantList>
        <**variant**\>
          <configItem>
            <name>chr</name>
            <shortDescription>chr</shortDescription>
            <description>Cherokee</description>
            <languageList>
              <iso639Id>chr</iso639Id>
            </languageList>
          </configItem>
        <**/variant**\>
        <variant>
        ...
        <variant>
```

It goes ahead with many variants. Basically the base.lst file is listing the
layouts and their children (layout-variants) and the base.xml enriches the
information about the parent layout and the layout variants.

## Putting pieces together

Once XKB is configured to load the specific “**us**” layout and the «\`» key is
hit, this happens:

1. the keyboard sends the key-code (49)
2. XKB applies the symbol found in the “keycodes/evdev” file for the key-code 49
   which is <TLDE>
3. XKB reads from the “us” layout rules written in “symbols/us” that <TLDE>
   corresponds to «\`» (or «~» if «SHIFT» is pressed) and returns the character.

## How to change XKB configuration

Whenever you modify any of the XKB files or when you want to try a different
layout among those already available the best option is to open a terminal and
use _setxkbmap_ to load the changes on the fly.

The simplest way is to run:

```
setxkbmap -layout us
```

but if you want the QWERTY US layout and the DVORAK US variant you can use:

```
setxkbmap -layout us,us -variant ,dvorak
```

Careful here, setxkbmap is picky about the syntax: the number of layouts and
variants must match. This is why “us” is repeated and “dvorak” is preceded by
the comma. It’s like: _\-layout us,us -variant «null»,dvorak_

You can load any layout variant this way. To have a list of the layout variants
currently available in your system, look for “xkb_symbols*”* in the “symbol/us”
file: the following name is the variant name*.*

```
rgrep “xkb\_symbols” symbols/us
```

Check your current XKB configuration with this:

```
setxkbmap -print -verbose 10
```

You should see something resembling this:

```
Setting verbose level to 10
locale is C
Trying to load rules file ./rules/evdev...
Success.
Applied rules from evdev:
rules:      evdev
model:      kinesis
layout:     us,us
variant:    ,kinesis\_adv\_dvorak\_it
options:    lv3:rwin\_switch,grp:alt\_space\_toggle
Trying to build keymap using the following components:
keycodes:   evdev+aliases(qwerty)
types:      complete
compat:     complete
symbols:    pc+us+us(kinesis\_adv\_dvorak\_it):2+inet(evdev)+group(alt\_space\_toggle)+level3(rwin\_switch)
geometry:   kinesis(model100)
xkb\_keymap {
 xkb\_keycodes  { include "evdev+aliases(qwerty)" };
 xkb\_types     { include "complete" };
 xkb\_compat    { include "complete" };
 xkb\_symbols   { include "pc+us+us(kinesis\_adv\_dvorak\_it):2+inet(evdev)+group(alt\_space\_toggle)+level3(rwin\_switch)" };
 xkb\_geometry  { include "kinesis(model100)" };
};
```

See the next paragraph to understand how to quickly switch between a different
layouts.

## XKB options

When running setxkbmap you can pass some options that can be very useful. For
instance you might want to specify that the «3rd level modifier» is the right
Windows key.

```
setxkbmap -layout us,us -variant ,dvorak -option "lv3:rwin\_switch"
```

If you have loaded more than one layout you will definitely need a shortcut
(let’s say «ALT»+«SPACE») to loop through them, so:

```
setxkbmap -layout us,us -variant ,dvorak -option "lv3:rwin\_switch,grp:alt\_space\_toggle"
```

**Note**: somehow XKB options are sticky. If you run again “setxkbmap -print
-verbose 10” you will see that the option “lv3:rwin_switch” is duplicated:

```
options:    lv3:rwin\_switch,grp:alt\_space\_toggle,lv3:rwin\_switch
```

To reset the options you need to run first the command:

```
setxkbmap -layout us,us -variant ,dvorak -option
```

Then:

```
setxkbmap -layout us,us -variant ,dvorak -option "lv3:rwin\_switch,grp:alt\_space\_toggle"
```

## Remapping keys

There are a number of ways to remap one or more keys of the keyboard.

**Long way:** If you plan to review the whole layout of your keyboard and master
it then you should follow the logic explained in this guide and create your own
layout-variant. It will take some time and a lot of patience. And you will
become a good friend of \_xev. \_Start with the “keycodes/evdev” file, if
necessary, and continue with the appropriate “symbols/«file»” where «file» is
the name of the parent layout you want to work with. I suggest to have a look at
my
[github repository](https://github.com/damko/xkb_kinesis_advantage_dvorak_layout)
in which I store all the configuration files for my custom DVORAK layout and
[compare](https://github.com/damko/xkb_kinesis_advantage_dvorak_layout/compare/master...hack)
the original files with the updated ones to see what I did.

Once you are done with all your changes and you have tested everything with
_setxkbmap_ you are ready to edit the _/etc/default/keyboard_ file to make the
changes permanent. (for inspiration, see my file above)

**Short way:** If you just need to remap few keys and you are in a rush,
_xmodmap_ is the most convenient way. Ex.: this will remap your Caps Lock into
the Escape button:

```
xmodmap -e "keycode 66 = Escape"
```

to make the remapping persistent you have to add the command in your ~/.Xmodmap
file

## Watch out

If you are a Gnome or Cinnamon user, be aware that these two window managers
have their own way to handle the keyboard settings and layouts which override
the XKB configuration. I’m not sure what KDE and others do but I can tell that
[I3 windows manager](https://i3wm.org/) definitely sticks to XKB.

No worries though, there is a way to force Gnome or Cinnamon to use XKB instead.
Adjust these commands to your needs and run them in the terminal.

```
gsettings set org.gnome.desktop.input-sources sources "\[('xkb', 'us+«variant\_name»'), ('xkb', 'us+«variant\_name»')\]"\# Update: 2017-10-25
\# Ex.:
\# gsettings set org.gnome.desktop.input-sources sources "\[('xkb', 'us+kinesis\_adv\_dvorak\_it'), ('xkb', 'us+rus')\]"
\# This command would load the US layout with "kinesis\_adv\_dvorak\_it" custom variant AND the US layout with the "russian" standard phonetic variant
\# If you check the menù "Input sources" in "Gnome Settings -> Region & Language" after runnig this command you'll see the layout/variants listedgsettings set org.gnome.desktop.input-sources xkb-options "\['lv3:caps\_switch,grp:alt\_space\_toggle'\]"\# "grp:alt\_space\_toggle" means that the shortcut "Alt+Space" (anywhere in the Desktop Environment) will sequentially load one of the available layouts/variants
```

Check your Gnome or Cinnamon settings with the utility _dconf-editor (sudo
apt-get install dconf-editor)_

## Update: 2016–06–18

In [this tweet](https://twitter.com/ErgoEmacs/status/744008146797006848) I’ve
been asked a smart question which goes like this:

> If a keyboard has programmable firmware, what’s your reason to deal with XKB?

From my experience, for these reasons:

1. _multiple layouts for multilingual writers using different charsets_: if you
   speak, say, English and Russian (I’m slowly studying Russian and Bulgarian)
   if you will need to switch between Latin charset and Cyrillic. I’m pretty
   sure that some programmable keyboards can have different lawyers and one
   charset for each layer but not all the programmable keyboards can be that
   flexible.
2. _specific XKB features_: XKB offers some features that a keyboard firmware
   can hardly provide and it can be more granular that a keyboard firmware.
   Conside these XKB options: \* caps:none: disables the CAPS LOCK \*
   shift:both_capslock: activates CAPS LOCK by pressing the two SHIFTS
   together \* lv3:rwin_switch: sets which key activates the 3rd level modifier
   is used to print the symbols displayed on the right side of some keyboard
   keys like “ ° € ™ ® Á ù ” (see the Italian QWERTY layout above). In this
   case lv3 is the Right Window key but you can set something else.
3. _Remapping 3rd level symbols_. Take English and Italian: they share the same
   Latin charset but English doesn’t use (anymore as far as I know) vowel with
   diacritics like: à ò è ù ì or á ó è ú í . Italian does. With XKB I was
   capable to remap these frequent vowels “à ò è ù ì” in a more comfortable
   position. Check out
   [this file](https://raw.githubusercontent.com/damko/xkb_kinesis_advantage_dvorak_layout/hack/symbols/us)
   and look for “kinesis_adv_dvorak_it”
4. _Consistency across Windows managers_. As mentioned above each Window Manager
   handles the keyboard its own way. I like to have the freedom to try new
   Window Managers but to keep control over my keyboard settings so I force the
   WM to use XKB and everything always works as expected.
