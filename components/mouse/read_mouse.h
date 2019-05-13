#ifndef _MOUSE_H
#define _NOUSE_H

struct mouse_info {
  int x, y;
  int button;	
};

extern void init_mouse();
extern void read_mouse(struct mouse_info *);

#endif