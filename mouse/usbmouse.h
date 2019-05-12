#ifndef _USBMOUSE_H
#define _USBMOUSE_H

#include <libusb-1.0/libusb.h>

#define USB_HID_MOUSE_PROTOCOL 2


/* Modifier bits */
#define USB_LCTRL  (1 << 0)

struct usb_mouse_packet {
  uint8_t modifiers;
  uint8_t pos_x;
  uint8_t pos_y;
};

/* Find and open a USB keyboard device.  Argument should point to
   space to store an endpoint address.  Returns NULL if no keyboard
   device was found. */
extern struct libusb_device_handle *openmouse(uint8_t *);

#endif
