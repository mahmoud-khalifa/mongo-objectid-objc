#import "MongoID.h"

@implementation MongoID
static int counter = -1;
static int mid = 0;

+ (void) initialize {
    counter = rand() & 0xffffff;
    NSUUID *udid = [[UIDevice currentDevice] identifierForVendor];
    unsigned char data[16];
    
    [udid getUUIDBytes:data];
    int d = 0xffffff;
    for(int i = 0; i < 16; i += 3) {
        int x = data[i%16] + (data[(i+1) % 16] << 8) + (data[(i + 2) % 16] << 16);
        d = (d ^ x) & 0xffffff;
    }
    mid = d & 0xffffff;

}
+ (ObjectID) id {
    counter++;
    if (counter >= 0xffffff) {
        counter = 0;
    }
    ObjectID _id;
    _id.m[2] = time(0);
    UInt16 pid = getpid();
    UInt8 pidHigh = pid >> 8;
    UInt8 pidLow = pid & 0xff;
    _id.m[1] = pidLow + (mid << 8);
    _id.m[0] = counter + (pidHigh << 24);
    return _id;
}

+ (NSString *) stringWithId: (ObjectID) _id {
    return [NSString stringWithFormat:@"%08x%08x%08x", (unsigned int)_id.m[2], (unsigned int)_id.m[1], (unsigned int)_id.m[0]];
}

+ (ObjectID) idWithString:(NSString *) string {
    ObjectID _id;
    NSScanner *scanner = [ NSScanner scannerWithString:string];
    
    unsigned int a, b, c;
    
    [scanner setScanLocation:0];
    [scanner scanHexInt:&a];
    
    [scanner setScanLocation:4];
    [scanner scanHexInt:&b];
    
    [scanner setScanLocation:8];
    [scanner scanHexInt:&c];
    _id.m[2] = a;
    _id.m[1] = b;
    _id.m[2] = c;
    return _id;
}
@end