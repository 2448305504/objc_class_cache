
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <objc/message.h>
#import "MyPerson.h"

typedef uint32_t mask_t;  // x86_64 & arm64 asm are less efficient

//preopt_cache_entry_t源码模仿
struct lg_preopt_cache_entry_t {
    uint32_t sel_offs;
    uint32_t imp_offs;
};

//preopt_cache_t源码模仿
struct lg_preopt_cache_t {
    int32_t  fallback_class_offset;
    union {
        struct {
            uint16_t shift       :  5;
            uint16_t mask        : 11;
        };
        uint16_t hash_params;
    };
    uint16_t occupied    : 14;
    uint16_t has_inlines :  1;
    uint16_t bit_one     :  1;
    struct lg_preopt_cache_entry_t entries;
    
    inline int capacity() const {
        return mask + 1;
    }
};

//bucket_t源码模仿
struct lg_bucket_t {
    IMP _imp;
    SEL _sel;
};

//cache_t源码模仿
struct lg_cache_t {
    uintptr_t _bucketsAndMaybeMask; // 8
    struct lg_preopt_cache_t _originalPreoptCache; // 8
    
    // _bucketsAndMaybeMask is a buckets_t pointer in the low 48 bits
    // _maybeMask is unused, the mask is stored in the top 16 bits.

    // How much the mask is shifted by.
    static constexpr uintptr_t maskShift = 48;

    // Additional bits after the mask which must be zero. msgSend
    // takes advantage of these additional bits to construct the value
    // `mask << 4` from `_maskAndBuckets` in a single instruction.
    static constexpr uintptr_t maskZeroBits = 4;

    // The largest mask value we can store.
    static constexpr uintptr_t maxMask = ((uintptr_t)1 << (64 - maskShift)) - 1;
    
    // The mask applied to `_maskAndBuckets` to retrieve the buckets pointer.
    static constexpr uintptr_t bucketsMask = ((uintptr_t)1 << (maskShift - maskZeroBits)) - 1;
    
    static constexpr uintptr_t preoptBucketsMarker = 1ul;

    // 63..60: hash_mask_shift
    // 59..55: hash_shift
    // 54.. 1: buckets ptr + auth
    //      0: always 1
    static constexpr uintptr_t preoptBucketsMask = 0x007ffffffffffffe;
    
    lg_bucket_t *buckets() {
        return (lg_bucket_t *)(_bucketsAndMaybeMask & bucketsMask);
    }
    
    uint32_t mask() const {
        return _bucketsAndMaybeMask >> maskShift;
    }
    
};

//class_data_bits_t源码模仿
struct lg_class_data_bits_t {
    uintptr_t objc_class;
};

//类源码模仿
struct lg_objc_class {
    Class isa;
    Class superclass;
    struct lg_cache_t cache;
    struct lg_class_data_bits_t bits;
};


void test(Class cls) {
    
    //将person的类型转换成自定义的源码ff_objc_class类型，方便后续操作
    struct lg_objc_class *pClass = (__bridge struct lg_objc_class *)(cls);
    
    struct lg_cache_t cache = pClass->cache;
    struct lg_bucket_t * buckets = cache.buckets();
    struct lg_preopt_cache_t origin = cache._originalPreoptCache;
    uintptr_t mask = cache.mask();
    
    
    NSLog(@"桶子里缓存方法的个数 = %u, 桶子的长度 = %lu",origin.occupied,mask+1);
    
    //打印buckets
    for (int i = 0; i < mask + 1; i++ ) {
        SEL sel = buckets[i]._sel;
        IMP imp = buckets[i]._imp;
        NSLog(@"%@-%p",NSStringFromSelector(sel),imp);
    }
    
}

int main(int argc, char * argv[]) {

    @autoreleasepool {
        MyPerson *p = [MyPerson alloc];
        [p method1];
        test(MyPerson.class);
        [p method2];
        test(MyPerson.class);
        [p method3];
        test(MyPerson.class);
        [p method4];
        test(MyPerson.class);
        [p method5];
        test(MyPerson.class);
        [p method6];
        test(MyPerson.class);
        [p method7];
        test(MyPerson.class);
        [p method8];
        test(MyPerson.class);
        [p method9];
        test(MyPerson.class);
        [p method10];
        test(MyPerson.class);
        [p method11];
        test(MyPerson.class);
        [p method12];
        test(MyPerson.class);
        [p method13];
        test(MyPerson.class);
        [p method14];
        test(MyPerson.class);
        [p method15];
        test(MyPerson.class);
        [p method16];
        test(MyPerson.class);
        [p method17];
        test(MyPerson.class);
        [p method18];
        test(MyPerson.class);
        [p method19];
        test(MyPerson.class);
        [p method20];
        test(MyPerson.class);
        [p method21];
        test(MyPerson.class);
        [p method22];
        test(MyPerson.class);
        [p method23];
        test(MyPerson.class);
        [p method24];
        test(MyPerson.class);
        [p method25];
        test(MyPerson.class);
        [p method26];
        test(MyPerson.class);
        [p method27];
        test(MyPerson.class);
        [p method28];
        test(MyPerson.class);
        [p method29];
        test(MyPerson.class);
        [p method30];
        test(MyPerson.class);
        
        
    }
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
}
