#ifndef _LINUX_PIDFD_H
#define _LINUX_PIDFD_H

struct file;
int pidfd_prepare(pid_t pid, unsigned int flags, struct file **f);
int __pidfd_prepare(pid_t pid, unsigned int flags, struct file **f);

#endif /* _LINUX_PIDFD_H */
