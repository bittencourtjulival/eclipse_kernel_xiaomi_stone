#ifndef _LINUX_FASTCHGTOGGLE_H
#define _LINUX_FASTCHGTOGGLE_H

#define FAST_CHARGE_30W 2
#define FAST_CHARGE_15W 1 
#define FAST_CHARGE_8W  0

extern int fast_chg_mode;
extern bool thermal_boost_enabled;

int fast_chg_get_mode(void);
bool thermal_boost_allowed(void);

#endif
