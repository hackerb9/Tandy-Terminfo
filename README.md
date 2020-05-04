# Tandy-Terminfo
Tandy Model 100, 102, 200 Terminfo for screen control on UNIX machines

## What is this?
When using the TELCOM terminal program on a Tandy portable computer such as the Model 200, the remote host needs to know how to send escape sequences to do things like clear the screen, move the cursor, show text in reverse, and so on. In UNIX, that information is stored in the TERMINFO database and then used by setting the TERM environment variable. 

This repository provides both the [source TERMINFO](tandy.terminfo) file and the [compiled versions](.terminfo/t/). 

## Installation
Download the [source TERMINFO](tandy.terminfo) file and compile it with `tic` on your UNIX host.

    tic tandy.terminfo
    
That will create the proper files in your `.terminfo` directory so they can be used immediately.

## Usage
Set your TERM environment variable to one of the available terminal types (see below) to inform programs how to talk to your Tandy. For example,

    export TERM=td200
    
There are different terminal types for the Model 100 (`td100`) and the
Model 200 (`td200`) as those have a different number of lines.

<img src="README.md.d/labelbutton.jpg" align="right">
There are also different types depending upon whether you have your
status line disabled or not. By default it is presumed you will
disable the status line by pressing the LABEL button. If you do not
wish to disable the status line, use the `-s` variant, like so,

    export TERM=td200-s
    
For convenience, there are aliases so you can refer to the TERM by
number of lines instead of whether it has a status line (`td200-15`).

## The list of available terminals

* `td200`: Tandy Model 200 (no status line). 40 columns x 16 rows.
  Aliases: `td200-ns`, `td200-16`.
* `td200-s`: Tandy Model 200 (has status line). 40 columns x 15 rows.
  Alias:`td200-15`.
* `td100`: Tandy Model 100 (no status line). 40 columns x 8 rows.
  Aliases: `td100-ns`, `td100-8`
* `td100-s`: Tandy Model 100 (has status line). 40 columns x 7 rows.
  Alias: `td100-7`
* `td102`: Tandy Model 102 (no status line). 40 columns x 8 rows.
  Aliases: `td102-ns`, `td102-8`
* `td102-s`: Tandy Model 102 (has status line). 40 columns x 7 rows.
  Alias: `td102-7`

## Suggestions

While setting the `TERM` environment variable will get you most of the
way to a usable interface, there are some other commands which I
recommend running when using a Tandy portable as a terminal. You can
put these in your `.bash_profile` so they'll be sourced when you login
or you can put them in a file and use `source filename` to read the
commands into your current shell.

    # Set terminal type to Tandy 200 with no status line
    export TERM=td200-ns
    # Turn on software flow control (^S/^Q)
    stty ixon ixoff
    # Send ASCII, not Unicode UTF-8 characters
    export LANG=C
    # Some programs don't pay attention to the size in the TERMINFO
    stty rows 16 cols 40
    # Backspace key sends ^H not ^?
    stty erase ^H

## Testing

You can test whether it worked by pressing Control-L. If it clears the
screen, then you have correctly installed the TERMINFO files. You can
also try running a `curses` program, such as the BSD game "worms"
which animates ASCII worms crawling on your screen. (`apt install
bsdgames`)

## Problems

* If you have trouble with the screen ocassionally scrolling, be sure
  you have the status line turned off by pressing the LABEL button.

* If you are trying to use the arrow keys, many applications will not
  accept them because Tandy's TELCOM program sends them as simple
  control-key characters instead of escape sequences.

        key_up=^^, key_down=^_,
        key_left=^], key_right=^\,

* If control-L clears the screen, but certain programs show
  uninterpreted escape sequences (e.g., `0;m`), then the problem is
  that those programs are not using TERMINFO correctly. They are
  instead implementing VT102 or "ANSI" terminal escape sequences
  themselves which not only is redundant work, it is incorrect.

  Reportedly buggy programs:
  * man and pacman
  * bash's PS1 prompt
  * w3m (works if *Display With Color* option is set to 0, `w3m -color=0`)
  * git (works, but shows `31m` for colors). 

  You can test if an application is indeed buggy by running `xterm -ti
  vt52 -tn vt52`. If that terminal shows the same errors as on your
  Tandy Model 100/102/200, then it is the program that is at fault and
  you should file a bug report with that project. On the other hand,
  if vt52 works (does not show escape sequences) but Tandy doesn't,
  please file a bug with this project. Bug reports are always
  appreciated.

# Notes on using the TELCOM program

* For a standard serial port @9600 baud, type this command in TELCOM:

    stat 88n1enn

* 19200 bps works fine if your UNIX getty is configured to talk that speed:

    stat 98n1enn

* Software flow control (XON/XOFF) is absolutely necessary as the 8250 UART has a one byte buffer. 

* Hardware flow control (RTS/CTS) is not available.

* Because of network latency software flow control may be inadequate over `ssh`.

* To connect to a PC running UNIX, you'll need a null modem cable.

* The Tandy Model 200 has a *FEMALE* 25 pin RS-232c port. 

## Special keys:

    \    GRPH -          Backslash
    |    GRPH SHIFT _    Pipe
    `    GRPH [          Backtick
    ~    GRPH SHIFT ]    Tilde
    {    GRPH 9          Open curly brace
    }    GRPH 0          Close curly brace
    ^@   GRPH P          Sends 0x80, useful in Emacs to set the mark 

Note that Tandy docs say CTRL-@ is supposed to work, but it does not.

## History

This started out as a woefully inadequate TERMCAP entry for Xenix in
the back of the Radio Shack manual. It claims to be based on the DEC
VT52, but that seems [approximate](compare.vt52) at best.

Just for historical interest, here is the original Tandy 16/Xenix
termcap entry from page 72 of the TELCOM Manual:

    n1|td200|Tandy 200:\
      :am:bs:xt:co#40:li#16:al=\EL:dl=\EM:cd=^L:ce=\EK:cl=\EE:cm=\EY%+ %+ :\
      :nd=^\:dn=^_:up=\EA:se=\Eq:so=\Ep:kl=^J:kr=^^:ku=^^:kd=^_:

## Future

This will hopefully eventually be added to the official TERMINFO databases used by BSD and GNU/Linux systems, but it'd be good to find out all the undocumented features before doing that. 

### Questions

* How does one write to the status line? 
  It's not vt52 as that didn't have tsl/fsl.
  h19? Nope. Didn't quite work.
  vt100-s? Nope. Failed completely.
  Wyse 50 labels? TODO.
* Is it possible to read the Function keys? 
* What about VT100 line drawing characters?
* Should the `td200` entry default to presuming the status line _off_ (which is the preferred way to use it) or _on_ (which is how the TELCOM software always starts up). 
* Can the TELECOM status line be switched on and off by escape codes? 
* Eight bit codes show up as graphics characters, but they are not in
  Latin-1 order. Is there something that can be done about that? It'd
  be nice to have umlauts and such


# Enabling a serial login on Unix systems with systemd and agetty

If you have a UNIX box running `systemd`, such as Debian GNU/Linux,
you can enable a serial port login like so:

    systemctl enable serial-getty@ttyS0
    systemctl start serial-getty@ttyS0

Presuming you have a serial port on `ttyS0`, of course. If you have a
USB to serial converter, try `ttyACM0`.

### Optional: allow different baud rates

The default baud rates should work with the Tandy portables as 9600 is
one of the standard ones. However, I wanted to allow both higher and
lower speeds. 

There may be a way to change the baud rates accepted using systemd,
but I don't know it. What I did is copy over the symlink that `enable`
created and then edited the file by hand.

    cd /etc/systemd/system/getty.target.wants/
    rm serial-getty@ttyS0.service
    cp /lib/systemd/system/serial-getty@.service serial-getty@ttyS0.service
    emacs serial-getty@ttyS0.service

If you set the baud rate to multiple values, the agetty program will
switch to the next one, if it's at the wrong speed, whenever you hit
the ENTER key. For example, you could use the following:

    ExecStart=-/sbin/agetty 115200,19200,9600,300 %I $TERM

When you connect with your Tandy portable, you'll see some garbage
characters instead of a Login prompt because it is talking at 115,200
bps. When you hit Enter, it'll try again at 19200. If you still get
line noise, hit Enter once more for 9600.

## Further Reading

* terminfo(5) - terminal capability data base
* tic(1) - the TERMINFO entry-description compiler
* infocmp(1) - compare or print out TERMINFO descriptions
* [Tandy 200 TELCOM manual](https://archive.org/details/Telcom_for_Tandy_200_1985_Microsoft)
