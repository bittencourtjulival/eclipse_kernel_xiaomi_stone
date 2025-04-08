#include <linux/module.h>
#include <linux/kobject.h>
#include <linux/sysfs.h>
#include <linux/power_supply.h>
#include <misc/fastchgtoggle.h>

int fast_chg_mode = FAST_CHARGE_30W;
bool thermal_boost_enabled = false;

int fast_chg_get_mode(void)
{
    return fast_chg_mode;
}

bool thermal_boost_allowed(void)
{
    return thermal_boost_enabled;
}

static ssize_t mode_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    return sprintf(buf, "%d\n", fast_chg_mode);
}

static ssize_t mode_store(struct kobject *kobj, struct kobj_attribute *attr,
                         const char *buf, size_t count)
{
    int ret, val;
    
    ret = kstrtoint(buf, 10, &val);
    if (ret < 0)
        return ret;

    if (val >= FAST_CHARGE_8W && val <= FAST_CHARGE_30W)
        fast_chg_mode = val;
    
    return count;
}

static ssize_t thermals_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    return sprintf(buf, "%d\n", thermal_boost_enabled ? 1 : 0);
}

static ssize_t thermals_store(struct kobject *kobj, struct kobj_attribute *attr,
                            const char *buf, size_t count)
{
    int ret, val;
    
    ret = kstrtoint(buf, 10, &val);
    if (ret < 0)
        return ret;

    thermal_boost_enabled = (val != 0);
    
    return count;
}

static struct kobj_attribute mode_attr = __ATTR(mode, 0664, mode_show, mode_store);
static struct kobj_attribute thermals_attr = __ATTR(thermals, 0664, thermals_show, thermals_store);

static struct attribute *attrs[] = {
    &mode_attr.attr,
    &thermals_attr.attr,
    NULL,
};

static struct attribute_group attr_group = {
    .attrs = attrs,
};

static struct kobject *fastchg_kobj;

static int __init fastchgtoggle_init(void)
{
    int ret;
    
    fastchg_kobj = kobject_create_and_add("fastchgtoggle", kernel_kobj);
    if (!fastchg_kobj)
        return -ENOMEM;
    
    ret = sysfs_create_group(fastchg_kobj, &attr_group);
    if (ret)
        kobject_put(fastchg_kobj);
    
    pr_info("Fast Charge Mode initialized\n");
    return ret;
}

static void __exit fastchgtoggle_exit(void)
{
    kobject_put(fastchg_kobj);
    pr_info("Fast Charge Mode removed\n");
}

module_init(fastchgtoggle_init);
module_exit(fastchgtoggle_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("KamiKaonashi");
MODULE_DESCRIPTION("Fast Charge Mode with thermal control");
