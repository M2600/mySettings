# Better performance with KDE on Nvidia

## nvidia xserver settings
- OpenGL Settings -> Allow Flipping: Unchecked

## ~/.config/plasma-workspace/env/kwin.sh
```bash
#!/bin/sh
export KWIN_TRIPLE_BUFFER=1
```

And make it executable:
```bash
chmod a+x ~/.config/plasma-workspace/env/kwin.sh
```

## Reboot
