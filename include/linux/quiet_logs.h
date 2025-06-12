#ifndef QUIET_LOGS_H
#define QUIET_LOGS_H

#include <linux/kernel.h>

/*
 * no_printk: evaluates format and args like printk, but does nothing.
 * Safe for variadic macros.
 */

#ifndef no_printk
#define no_printk(fmt, ...) ({ if (0) printk(fmt, ##__VA_ARGS__); 0; })
#endif

/* Disable pr_* macros */
#undef pr_err
#define pr_err(fmt, ...)     no_printk(fmt, ##__VA_ARGS__)

#undef pr_warn
#define pr_warn(fmt, ...)    no_printk(fmt, ##__VA_ARGS__)

#undef pr_info
#define pr_info(fmt, ...)    no_printk(fmt, ##__VA_ARGS__)

#undef pr_debug
#define pr_debug(fmt, ...)   no_printk(fmt, ##__VA_ARGS__)

/* Disable dev_* macros */
#undef dev_err
#define dev_err(dev, fmt, ...)   no_printk(fmt, ##__VA_ARGS__)

#undef dev_warn
#define dev_warn(dev, fmt, ...)  no_printk(fmt, ##__VA_ARGS__)

#undef dev_info
#define dev_info(dev, fmt, ...)  no_printk(fmt, ##__VA_ARGS__)

#undef dev_dbg
#define dev_dbg(dev, fmt, ...)   no_printk(fmt, ##__VA_ARGS__)

/* Disable adapter_* macros */
#undef adapter_err
#define adapter_err(fmt, ...) do { } while (0)

#undef adapter_info
#define adapter_info(fmt, ...) do { } while (0)

#undef adapter_dbg
#define adapter_dbg(fmt, ...) do { } while (0)

/* Disable class_* macros */
#undef class_err
#define class_err(fmt, ...) do { } while (0)

#undef class_info
#define class_info(fmt, ...) do { } while (0)

#undef class_dbg
#define class_dbg(fmt, ...) do { } while (0)

#endif /* QUIET_LOGS_H */
