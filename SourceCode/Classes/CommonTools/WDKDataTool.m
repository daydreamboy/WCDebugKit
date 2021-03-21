//
//  WDKDataTool.m
//  WDKDebugKit
//
//  Created by wesley_chen on 2021/3/21.
//

#import "WDKDataTool.h"

@implementation WDKMIMETypeInfo

#pragma mark - Public Methods

+ (nullable WDKMIMETypeInfo *)infoWithMIMEType:(WDKMIMEType)type {
    NSDictionary *dict = [[self allSupportMIMETypeInfos] objectForKey:@(type)];
    if (dict) {
        return [self infoWithDictionary:dict];
    }
    else {
        return nil;
    }
}

#pragma mark -

+ (instancetype)infoWithDictionary:(NSDictionary *)dict {
    WDKMIMETypeInfo *info = [[WDKMIMETypeInfo alloc] init];
    info.MIME = dict[@"mime"];
    info.extension = dict[@"ext"];
    info.type = [dict[@"type"] integerValue];
    info.bytesCount = [dict[@"bytesCount"] integerValue];
    info.matchBlock = dict[@"matches"];
    
    return info;
}

+ (NSDictionary<NSNumber *, NSDictionary *> *)allSupportMIMETypeInfos {
    
    static NSDictionary<NSNumber *, NSDictionary *> *sMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sMap = @{
                 @(WDKMIMETypeAmr): @{
                         @"mime": @"audio/amr",
                         @"ext": @"amr",
                         @"type": @(WDKMIMETypeAmr),
                         @"bytesCount": @6,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes[] = { 0x23, 0x21, 0x41, 0x4D, 0x52, 0x0A };
                             // [0, 5]
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeAr): @{
                         @"mime": @"application/x-unix-archive",
                         @"ext": @"ar",
                         @"type": @(WDKMIMETypeAr),
                         @"bytesCount": @7,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes[] = { 0x21, 0x3C, 0x61, 0x72, 0x63, 0x68, 0x3E };
                             // [0, 6]
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeAvi): @{
                         @"mime": @"video/x-msvideo",
                         @"ext": @"avi",
                         @"type": @(WDKMIMETypeAvi),
                         @"bytesCount": @11,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x52, 0x49, 0x46, 0x46 };
                             const unsigned char bytes2[] = { 0x41, 0x56, 0x49 };
                             
                             // [0, 4] and [8, 10]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             BOOL b2 = memcmp(byteOrder + 8, bytes2, sizeof(bytes2)) == 0;
                             
                             return (b1 && b2);
                         },
                         },
                 @(WDKMIMETypeBmp): @{
                         @"mime": @"image/bmp",
                         @"ext": @"bmp",
                         @"type": @(WDKMIMETypeBmp),
                         @"bytesCount": @2,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes[] = { 0x42, 0x4D };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeBz2): @{
                         @"mime": @"application/x-bzip2",
                         @"ext": @"bz2",
                         @"type": @(WDKMIMETypeBz2),
                         @"bytesCount": @3,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes[] = { 0x42, 0x5A, 0x68 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeCab): @{
                         @"mime": @"application/vnd.ms-cab-compressed",
                         @"ext": @"cab",
                         @"type": @(WDKMIMETypeCab),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x4D, 0x53, 0x43, 0x46 };
                             const unsigned char bytes2[] = { 0x49, 0x53, 0x63, 0x28 };
                             
                             // [0, 4]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             BOOL b2 = memcmp(byteOrder, bytes2, sizeof(bytes2)) == 0;
                             
                             return (b1 || b2);
                         },
                         },
                 @(WDKMIMETypeCr2): @{
                         @"mime": @"image/x-canon-cr2",
                         @"ext": @"cr2",
                         @"type": @(WDKMIMETypeCr2),
                         @"bytesCount": @10,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x49, 0x49, 0x2A, 0x00 };
                             const unsigned char bytes2[] = { 0x4D, 0x4D, 0x00, 0x2A };
                             const unsigned char bytes3[] = { 0x43, 0x52 };
                             
                             // [0, 4]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             BOOL b2 = memcmp(byteOrder, bytes2, sizeof(bytes2)) == 0;
                             // [8, 9]
                             BOOL b3 = memcmp(byteOrder + 8, bytes3, sizeof(bytes3)) == 0;
                             
                             return (b1 || b2) && b3;
                         },
                         },
                 @(WDKMIMETypeCrx): @{
                         @"mime": @"application/x-google-chrome-extension",
                         @"ext": @"crx",
                         @"type": @(WDKMIMETypeCrx),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x43, 0x72, 0x32, 0x34 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeDeb): @{
                         @"mime": @"application/x-deb",
                         @"ext": @"deb",
                         @"type": @(WDKMIMETypeDeb),
                         @"bytesCount": @21,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 20]
                             const unsigned char bytes[] = { 0x21, 0x3C, 0x61, 0x72, 0x63, 0x68, 0x3E, 0x0A, 0x64, 0x65, 0x62, 0x69,
                                 0x61, 0x6E, 0x2D, 0x62, 0x69, 0x6E, 0x61, 0x72, 0x79 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeDmg): @{
                         @"mime": @"application/x-apple-diskimage",
                         @"ext": @"dmg",
                         @"type": @(WDKMIMETypeDmg),
                         @"bytesCount": @2,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 1]
                             const unsigned char bytes[] = { 0x78, 0x01 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeEot): @{
                         @"mime": @"application/octet-stream",
                         @"ext": @"eot",
                         @"type": @(WDKMIMETypeEot),
                         @"bytesCount": @11,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x4C, 0x50 };
                             const unsigned char bytes2[] = { 0x00, 0x00, 0x01 };
                             const unsigned char bytes3[] = { 0x01, 0x00, 0x02 };
                             const unsigned char bytes4[] = { 0x02, 0x00, 0x02 };
                             
                             // [34, 35]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [8, 10]
                             BOOL b2 = memcmp(byteOrder + 8, bytes2, sizeof(bytes2)) == 0;
                             BOOL b3 = memcmp(byteOrder + 8, bytes3, sizeof(bytes3)) == 0;
                             BOOL b4 = memcmp(byteOrder + 8, bytes4, sizeof(bytes4)) == 0;
                             
                             return b1 && (b2 || b3 || b4);
                         },
                         },
                 @(WDKMIMETypeEpub): @{
                         @"mime": @"application/epub+zip",
                         @"ext": @"epub",
                         @"type": @(WDKMIMETypeEpub),
                         @"bytesCount": @58,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x50, 0x4B, 0x03, 0x04 };
                             const unsigned char bytes2[] = { 0x6D, 0x69, 0x6D, 0x65, 0x74, 0x79, 0x70, 0x65, 0x61, 0x70, 0x70, 0x6C,
                                 0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E, 0x2F, 0x65, 0x70, 0x75, 0x62,
                                 0x2B, 0x7A, 0x69, 0x70 };
                             
                             // [0, 3]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [30, 57]
                             BOOL b2 = memcmp(byteOrder + 30, bytes2, sizeof(bytes2)) == 0;
                             
                             return b1 && b2;
                         },
                         },
                 @(WDKMIMETypeExe): @{
                         @"mime": @"application/x-msdownload",
                         @"ext": @"exe",
                         @"type": @(WDKMIMETypeExe),
                         @"bytesCount": @2,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 1]
                             const unsigned char bytes[] = { 0x4D, 0x5A };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeFlac): @{
                         @"mime": @"audio/x-flac",
                         @"ext": @"flac",
                         @"type": @(WDKMIMETypeFlac),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x66, 0x4C, 0x61, 0x43 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeFlif): @{
                         @"mime": @"image/flif",
                         @"ext": @"flif",
                         @"type": @(WDKMIMETypeFlif),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 4]
                             const unsigned char bytes[] = { 0x46, 0x4C, 0x49, 0x46 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeFlv): @{
                         @"mime": @"video/x-flv",
                         @"ext": @"flv",
                         @"type": @(WDKMIMETypeFlv),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x46, 0x4C, 0x56, 0x01 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeGif): @{
                         @"mime": @"image/gif",
                         @"ext": @"gif",
                         @"type": @(WDKMIMETypeGif),
                         @"bytesCount": @3,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 2]
                             const unsigned char bytes[] = { 0x47, 0x49, 0x46 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeGz): @{
                         @"mime": @"application/gzip",
                         @"ext": @"gz",
                         @"type": @(WDKMIMETypeGz),
                         @"bytesCount": @3,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 2]
                             const unsigned char bytes[] = { 0x1F, 0x8B, 0x08 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeHeic): @{
                         // @see http://nokiatech.github.io/heif/technical.html
                         @"mime": @"image/heic",
                         @"ext": @"heic",
                         @"type": @(WDKMIMETypeHeic),
                         @"bytesCount": @12,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // @see https://github.com/rs/SDWebImage/blob/master/SDWebImage/NSData%2BImageContentType.m
                             // [4, 8]
                             const unsigned char bytes1[] = { 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63 }; // @"ftypheic"
                             const unsigned char bytes2[] = { 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x78 }; // @"ftypheix"
                             const unsigned char bytes3[] = { 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x76, 0x63 }; // @"ftyphevc"
                             const unsigned char bytes4[] = { 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x76, 0x78 }; // @"ftyphevx"
                             
                             if (memcmp(byteOrder + 4, bytes1, sizeof(bytes1)) == 0 ||
                                 memcmp(byteOrder + 4, bytes2, sizeof(bytes2)) == 0 ||
                                 memcmp(byteOrder + 4, bytes3, sizeof(bytes3)) == 0 ||
                                 memcmp(byteOrder + 4, bytes4, sizeof(bytes4)) == 0) {
                                 return YES;
                             }
                             
                             return NO;
                         },
                         },
                 @(WDKMIMETypeHeif): @{
                         @"mime": @"image/heif",
                         @"ext": @"heic",
                         @"type": @(WDKMIMETypeHeif),
                         @"bytesCount": @12,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [4, 8]
                             const unsigned char bytes1[] = { 0x66, 0x74, 0x79, 0x70, 0x6D, 0x69, 0x66, 0x31 }; // @"ftypmif1"
                             const unsigned char bytes2[] = { 0x66, 0x74, 0x79, 0x70, 0x6D, 0x73, 0x66, 0x31 }; // @"ftypmsf1"
                             
                             if (memcmp(byteOrder + 4, bytes1, sizeof(bytes1)) == 0 ||
                                 memcmp(byteOrder + 4, bytes2, sizeof(bytes2)) == 0) {
                                 return YES;
                             }
                             
                             return NO;
                         },
                         },
                 @(WDKMIMETypeIco): @{
                         @"mime": @"image/x-icon",
                         @"ext": @"ico",
                         @"type": @(WDKMIMETypeIco),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x00, 0x00, 0x01, 0x00 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeJpg): @{
                         @"mime": @"image/jpeg",
                         @"ext": @"jpg",
                         @"type": @(WDKMIMETypeJpg),
                         @"bytesCount": @3,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 2]
                             const unsigned char bytes[] = { 0xFF, 0xD8, 0xFF };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeJxr): @{
                         @"mime": @"image/vnd.ms-photo",
                         @"ext": @"jxr",
                         @"type": @(WDKMIMETypeJxr),
                         @"bytesCount": @3,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 2]
                             const unsigned char bytes[] = { 0x49, 0x49, 0xBC };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeLz): @{
                         @"mime": @"application/x-lzip",
                         @"ext": @"lz",
                         @"type": @(WDKMIMETypeLz),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x4C, 0x5A, 0x49, 0x50 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeM4a): @{
                         @"mime": @"audio/m4a",
                         @"ext": @"m4a",
                         @"type": @(WDKMIMETypeM4a),
                         @"bytesCount": @11,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x4D, 0x34, 0x41, 0x20 };
                             const unsigned char bytes2[] = { 0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x41 };
                             
                             // [0, 3]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [4, 10]
                             BOOL b2 = memcmp(byteOrder + 4, bytes2, sizeof(bytes2)) == 0;
                             
                             return b1 || b2;
                         },
                         },
                 @(WDKMIMETypeM4v): @{
                         @"mime": @"video/x-m4v",
                         @"ext": @"m4v",
                         @"type": @(WDKMIMETypeM4v),
                         @"bytesCount": @11,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 10]
                             const unsigned char bytes[] = { 0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x56 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeMid): @{
                         @"mime": @"audio/midi",
                         @"ext": @"mid",
                         @"type": @(WDKMIMETypeMid),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x4D, 0x54, 0x68, 0x64 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeMkv): @{
                         @"mime": @"video/x-matroska",
                         @"ext": @"mkv",
                         @"type": @(WDKMIMETypeMkv),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes[] = { 0x1A, 0x45, 0xDF, 0xA3 };
                             BOOL b1 = memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                             if (!b1) {
                                 return NO;
                             }
                             
                             NSInteger idPos = -1;
                             for (NSInteger i = 4; i < 4100; i++) {
                                 if (byteOrder[i] == 0x42 && byteOrder[i + 1] == 0x82) {
                                     idPos = i;
                                     break;
                                 }
                             }
                             
                             if (idPos == -1) {
                                 return NO;
                             }
                             
                             // Note: make 3 bytes shift
                             idPos += 3;
                             BOOL (^findDocType)(char *) = ^BOOL(char *type) {
                                 for (NSInteger i = 0; i < strlen(type); i++) {
                                     char ch = type[i];
                                     if (byteOrder[idPos + i] != ch) {
                                         return NO;
                                     }
                                 }
                                 
                                 return YES;
                             };
                             
                             return findDocType("matroska");
                         },
                         },
                 @(WDKMIMETypeMov): @{
                         @"mime": @"video/quicktime",
                         @"ext": @"mov",
                         @"type": @(WDKMIMETypeMov),
                         @"bytesCount": @8,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 7]
                             const unsigned char bytes[] = { 0x00, 0x00, 0x00, 0x14, 0x66, 0x74, 0x79, 0x70 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeMp3): @{
                         @"mime": @"audio/mpeg",
                         @"ext": @"mp3",
                         @"type": @(WDKMIMETypeMp3),
                         @"bytesCount": @3,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x49, 0x44, 0x33 };
                             const unsigned char bytes2[] = { 0xFF, 0xFB };
                             
                             // [0, 2]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [0, 1]
                             BOOL b2 = memcmp(byteOrder, bytes2, sizeof(bytes2)) == 0;
                             
                             return b1 || b2;
                         },
                         },
                 @(WDKMIMETypeMp4): @{
                         @"mime": @"video/mp4",
                         @"ext": @"mp4",
                         @"type": @(WDKMIMETypeMp4),
                         @"bytesCount": @28,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x00, 0x00, 0x00 };
                             const unsigned char bytes2[] = { 0x18 };
                             const unsigned char bytes3[] = { 0x20 };
                             const unsigned char bytes4[] = { 0x66, 0x74, 0x79, 0x70 };
                             const unsigned char bytes5[] = { 0x33, 0x67, 0x70, 0x35 };
                             const unsigned char bytes6[] = { 0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32 };
                             const unsigned char bytes7[] = { 0x6D, 0x70, 0x34, 0x31, 0x6D, 0x70, 0x34, 0x32, 0x69, 0x73, 0x6F, 0x6D };
                             const unsigned char bytes8[] = { 0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D };
                             const unsigned char bytes9[] = { 0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32, 0x00, 0x00, 0x00, 0x00 };
                             
                             // [0, 2]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [3]
                             BOOL b2 = memcmp(byteOrder + 3, bytes2, sizeof(bytes2)) == 0;
                             // [3]
                             BOOL b3 = memcmp(byteOrder + 3, bytes3, sizeof(bytes3)) == 0;
                             // [4, 7]
                             BOOL b4 = memcmp(byteOrder + 4, bytes4, sizeof(bytes4)) == 0;
                             // [0, 3]
                             BOOL b5 = memcmp(byteOrder, bytes5, sizeof(bytes5)) == 0;
                             // [0, 11]
                             BOOL b6 = memcmp(byteOrder, bytes6, sizeof(bytes6)) == 0;
                             // [16, 27]
                             BOOL b7 = memcmp(byteOrder + 16, bytes7, sizeof(bytes7)) == 0;
                             // [0, 11]
                             BOOL b8 = memcmp(byteOrder, bytes8, sizeof(bytes8)) == 0;
                             // [0, 15]
                             // REMARK: 原出处，仅判断了[0, 11]
                             BOOL b9 = memcmp(byteOrder, bytes9, sizeof(bytes9)) == 0;
                             
                             return (b1 && (b2 || b3) && b4) ||
                             (b5) ||
                             (b6 && b7) ||
                             (b8) ||
                             (b9);
                         },
                         },
                 @(WDKMIMETypeMpg): @{
                         @"mime": @"video/mpeg",
                         @"ext": @"mpg",
                         @"type": @(WDKMIMETypeMpg),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes[] = { 0x00, 0x00, 0x01 };
                             // [0, 2]
                             BOOL b1 = memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                             if (!b1) {
                                 return NO;
                             }
                             
                             // CHECK: need to test
                             NSString *character = [NSString stringWithFormat:@"%2X", bytes[3]];
                             if (![character isEqualToString:@"B"]) {
                                 return YES;
                             }
                             
                             return NO;
                         },
                         },
                 @(WDKMIMETypeMsi): @{
                         @"mime": @"application/x-msi",
                         @"ext": @"msi",
                         @"type": @(WDKMIMETypeMsi),
                         @"bytesCount": @8,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 7]
                             const unsigned char bytes[] = { 0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeMxf): @{
                         @"mime": @"application/mxf",
                         @"ext": @"mxf",
                         @"type": @(WDKMIMETypeMxf),
                         @"bytesCount": @14,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 13]
                             const unsigned char bytes[] = { 0x06, 0x0E, 0x2B, 0x34, 0x02, 0x05, 0x01, 0x01, 0x0D, 0x01, 0x02, 0x01, 0x01, 0x02 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeNes): @{
                         @"mime": @"application/x-nintendo-nes-rom",
                         @"ext": @"nes",
                         @"type": @(WDKMIMETypeNes),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x4E, 0x45, 0x53, 0x1A };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeOgg): @{
                         @"mime": @"audio/ogg",
                         @"ext": @"ogg",
                         @"type": @(WDKMIMETypeOgg),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x4F, 0x67, 0x67, 0x53 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeOpus): @{
                         @"mime": @"audio/opus",
                         @"ext": @"opus",
                         @"type": @(WDKMIMETypeOpus),
                         @"bytesCount": @36,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3], `OggS`
                             const unsigned char bytes1[] = { 0x4F, 0x67, 0x67, 0x53 };
                             // [28, 35], `OpusHead`
                             const unsigned char bytes2[] = { 0x4F, 0x70, 0x75, 0x73, 0x48, 0x65, 0x61, 0x64 };
                             
                             // Note: Needs to be before `ogg` check
                             if (memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0 && memcmp(byteOrder + 28, bytes2, sizeof(bytes2)) == 0) {
                                 return YES;
                             }
                             
                             return NO;
                         },
                         },
                 @(WDKMIMETypeOtf): @{
                         @"mime": @"application/font-sfnt",
                         @"ext": @"otf",
                         @"type": @(WDKMIMETypeOtf),
                         @"bytesCount": @5,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 4]
                             const unsigned char bytes[] = { 0x4F, 0x54, 0x54, 0x4F, 0x00 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypePdf): @{
                         @"mime": @"application/pdf",
                         @"ext": @"pdf",
                         @"type": @(WDKMIMETypePdf),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x25, 0x50, 0x44, 0x46 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypePng): @{
                         @"mime": @"image/png",
                         @"ext": @"png",
                         @"type": @(WDKMIMETypePng),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x89, 0x50, 0x4E, 0x47 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypePs): @{
                         @"mime": @"application/postscript",
                         @"ext": @"ps",
                         @"type": @(WDKMIMETypePs),
                         @"bytesCount": @2,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 1]
                             const unsigned char bytes[] = { 0x25, 0x21 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypePsd): @{
                         @"mime": @"image/vnd.adobe.photoshop",
                         @"ext": @"psd",
                         @"type": @(WDKMIMETypePsd),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x38, 0x42, 0x50, 0x53 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeRar): @{
                         @"mime": @"application/x-rar-compressed",
                         @"ext": @"rar",
                         @"type": @(WDKMIMETypeRar),
                         @"bytesCount": @7,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x52, 0x61, 0x72, 0x21, 0x1A, 0x07 };
                             const unsigned char bytes2[] = { 0x0 };
                             const unsigned char bytes3[] = { 0x1 };
                             
                             // [0, 5]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [6]
                             BOOL b2 = memcmp(byteOrder + 6, bytes2, sizeof(bytes2)) == 0;
                             // [6]
                             BOOL b3 = memcmp(byteOrder + 6, bytes3, sizeof(bytes3)) == 0;
                             
                             return (b1 && (b2 || b3));
                         },
                         },
                 @(WDKMIMETypeRpm): @{
                         @"mime": @"application/x-rpm",
                         @"ext": @"rpm",
                         @"type": @(WDKMIMETypeRpm),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0xED, 0xAB, 0xEE, 0xDB };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeRtf): @{
                         @"mime": @"application/rtf",
                         @"ext": @"rtf",
                         @"type": @(WDKMIMETypeRtf),
                         @"bytesCount": @5,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 4]
                             const unsigned char bytes[] = { 0x7B, 0x5C, 0x72, 0x74, 0x66 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMEType7z): @{
                         @"mime": @"application/x-7z-compressed",
                         @"ext": @"7z",
                         @"type": @(WDKMIMEType7z),
                         @"bytesCount": @6,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 5]
                             const unsigned char bytes[] = { 0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeSqlite): @{
                         @"mime": @"application/x-sqlite3",
                         @"ext": @"sqlite",
                         @"type": @(WDKMIMETypeSqlite),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 3]
                             const unsigned char bytes[] = { 0x53, 0x51, 0x4C, 0x69 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeSwf): @{
                         @"mime": @"application/x-shockwave-flash",
                         @"ext": @"swf",
                         @"type": @(WDKMIMETypeSwf),
                         @"bytesCount": @3,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x43 };
                             const unsigned char bytes2[] = { 0x46 };
                             const unsigned char bytes3[] = { 0x57, 0x53 };
                             
                             // [0]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [0]
                             BOOL b2 = memcmp(byteOrder, bytes2, sizeof(bytes2)) == 0;
                             // [1, 2]
                             BOOL b3 = memcmp(byteOrder + 1, bytes3, sizeof(bytes3)) == 0;
                             
                             return ((b1 || b2) && b3);
                         },
                         },
                 @(WDKMIMETypeTar): @{
                         @"mime": @"application/x-tar",
                         @"ext": @"tar",
                         @"type": @(WDKMIMETypeTar),
                         @"bytesCount": @262,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [257, 261]
                             const unsigned char bytes[] = { 0x75, 0x73, 0x74, 0x61, 0x72 };
                             return memcmp(byteOrder + 257, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeTif): @{
                         @"mime": @"image/tiff",
                         @"ext": @"tif",
                         @"type": @(WDKMIMETypeTif),
                         @"bytesCount": @4,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x49, 0x49, 0x2A, 0x00 };
                             const unsigned char bytes2[] = { 0x4D, 0x4D, 0x20, 0x2A };
                             
                             // [0, 3]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [0, 3]
                             BOOL b2 = memcmp(byteOrder, bytes2, sizeof(bytes2)) == 0;
                             
                             return b1 || b2;
                         },
                         },
                 @(WDKMIMETypeTtf): @{
                         @"mime": @"application/font-sfnt",
                         @"ext": @"ttf",
                         @"type": @(WDKMIMETypeTtf),
                         @"bytesCount": @5,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 4]
                             const unsigned char bytes[] = { 0x00, 0x01, 0x00, 0x00, 0x00 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeWav): @{
                         @"mime": @"audio/x-wav",
                         @"ext": @"wav",
                         @"type": @(WDKMIMETypeWav),
                         @"bytesCount": @12,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x52, 0x49, 0x46, 0x46 };
                             const unsigned char bytes2[] = { 0x57, 0x41, 0x56, 0x45 };
                             
                             // [0, 3]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [8, 11]
                             BOOL b2 = memcmp(byteOrder + 8, bytes2, sizeof(bytes2)) == 0;
                             
                             return b1 && b2;
                         },
                         },
                 @(WDKMIMETypeWebm): @{
                         @"mime": @"video/webm",
                         @"ext": @"webm",
                         @"type": @(WDKMIMETypeWebm),
                         @"bytesCount": @6,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes[] = { 0x1A, 0x45, 0xDF, 0xA3 };
                             BOOL b1 = memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                             if (!b1) {
                                 return NO;
                             }
                             
                             NSInteger idPos = -1;
                             for (NSInteger i = 4; i < 4100; i++) {
                                 if (byteOrder[i] == 0x42 && byteOrder[i + 1] == 0x82) {
                                     idPos = i;
                                     break;
                                 }
                             }
                             
                             if (idPos == -1) {
                                 return NO;
                             }
                             
                             // Note: make 3 bytes shift
                             idPos += 3;
                             BOOL (^findDocType)(char *) = ^BOOL(char *type) {
                                 for (NSInteger i = 0; i < strlen(type); i++) {
                                     char ch = type[i];
                                     if (byteOrder[idPos + i] != ch) {
                                         return NO;
                                     }
                                 }
                                 
                                 return YES;
                             };
                             
                             return findDocType("webm");
                         },
                         },
                 @(WDKMIMETypeWebp): @{
                         @"mime": @"image/webp",
                         @"ext": @"webp",
                         @"type": @(WDKMIMETypeWebp),
                         @"bytesCount": @12,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [8, 11]
                             const unsigned char bytes[] = { 0x57, 0x45, 0x42, 0x50 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeWmv): @{
                         @"mime": @"video/x-ms-wmv",
                         @"ext": @"wmv",
                         @"type": @(WDKMIMETypeWmv),
                         @"bytesCount": @10,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 9]
                             const unsigned char bytes[] = { 0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11, 0xA6, 0xD9 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeWoff): @{
                         @"mime": @"application/font-woff",
                         @"ext": @"woff",
                         @"type": @(WDKMIMETypeWoff),
                         @"bytesCount": @8,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x77, 0x4F, 0x46, 0x46 };
                             const unsigned char bytes2[] = { 0x00, 0x01, 0x00, 0x00 };
                             const unsigned char bytes3[] = { 0x4F, 0x54, 0x54, 0x4F };
                             
                             // [0, 3]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [4, 7]
                             BOOL b2 = memcmp(byteOrder + 4, bytes2, sizeof(bytes2)) == 0;
                             // [4, 7]
                             BOOL b3 = memcmp(byteOrder + 4, bytes3, sizeof(bytes3)) == 0;
                             
                             return b1 && (b2 || b3);
                         },
                         },
                 @(WDKMIMETypeWoff2): @{
                         @"mime": @"application/font-woff",
                         @"ext": @"woff2",
                         @"type": @(WDKMIMETypeWoff2),
                         @"bytesCount": @8,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x77, 0x4F, 0x46, 0x32 };
                             const unsigned char bytes2[] = { 0x00, 0x01, 0x00, 0x00 };
                             const unsigned char bytes3[] = { 0x4F, 0x54, 0x54, 0x4F };
                             
                             // [0, 3]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [4, 7]
                             BOOL b2 = memcmp(byteOrder + 4, bytes2, sizeof(bytes2)) == 0;
                             // [4, 7]
                             BOOL b3 = memcmp(byteOrder + 4, bytes3, sizeof(bytes3)) == 0;
                             
                             return b1 && (b2 || b3);
                         },
                         },
                 @(WDKMIMETypeXpi): @{
                         @"mime": @"application/x-xpinstall",
                         @"ext": @"xpi",
                         @"type": @(WDKMIMETypeXpi),
                         @"bytesCount": @50,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // Needs to be before `zip` check
                             // assumes signed .xpi from addons.mozilla.org
                             BOOL isZip = NO;
                             {
                                 const unsigned char bytes1[] = { 0x50, 0x4B };
                                 const unsigned char bytes2[] = { 0x3 };
                                 const unsigned char bytes3[] = { 0x5 };
                                 const unsigned char bytes4[] = { 0x7 };
                                 const unsigned char bytes5[] = { 0x4 };
                                 const unsigned char bytes6[] = { 0x6 };
                                 const unsigned char bytes7[] = { 0x8 };
                                 
                                 // [0, 1]
                                 BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                                 // [2]
                                 BOOL b2 = memcmp(byteOrder + 2, bytes2, sizeof(bytes2)) == 0;
                                 // [2]
                                 BOOL b3 = memcmp(byteOrder + 2, bytes3, sizeof(bytes3)) == 0;
                                 // [2]
                                 BOOL b4 = memcmp(byteOrder + 2, bytes4, sizeof(bytes4)) == 0;
                                 // [3]
                                 BOOL b5 = memcmp(byteOrder + 3, bytes5, sizeof(bytes5)) == 0;
                                 // [3]
                                 BOOL b6 = memcmp(byteOrder + 3, bytes6, sizeof(bytes6)) == 0;
                                 // [3]
                                 BOOL b7 = memcmp(byteOrder + 3, bytes7, sizeof(bytes7)) == 0;
                                 
                                 isZip = b1 && (b2 || b3 || b4) && (b5 || b6 || b7);
                             }
                             
                             if (isZip) {
                                 const unsigned char bytes1[] = { 0x50, 0x4B, 0x03, 0x04 };
                                 const unsigned char bytes2[] = { 0x4D, 0x45, 0x54, 0x41, 0x2D, 0x49, 0x4E, 0x46, 0x2F, 0x6D, 0x6F, 0x7A,
                                     0x69, 0x6C, 0x6C, 0x61, 0x2E, 0x72, 0x73, 0x61 };
                                 
                                 // [0, 3]
                                 BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                                 // [30, 49]
                                 BOOL b2 = memcmp(byteOrder + 30, bytes2, sizeof(bytes2)) == 0;
                                 
                                 return b1 && b2;
                             }
                             
                             return NO;
                         },
                         },
                 @(WDKMIMETypeXz): @{
                         @"mime": @"application/x-xz",
                         @"ext": @"xz",
                         @"type": @(WDKMIMETypeXz),
                         @"bytesCount": @6,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             // [0, 5]
                             const unsigned char bytes[] = { 0xFD, 0x37, 0x7A, 0x58, 0x5A, 0x00 };
                             return memcmp(byteOrder, bytes, sizeof(bytes)) == 0;
                         },
                         },
                 @(WDKMIMETypeZ): @{
                         @"mime": @"application/x-compress",
                         @"ext": @"z",
                         @"type": @(WDKMIMETypeZ),
                         @"bytesCount": @2,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x1F, 0xA0 };
                             const unsigned char bytes2[] = { 0x1F, 0x9D };
                             
                             // [0, 1]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [0, 1]
                             BOOL b2 = memcmp(byteOrder, bytes2, sizeof(bytes2)) == 0;
                             
                             return b1 || b2;
                         },
                         },
                 @(WDKMIMETypeZip): @{
                         @"mime": @"application/zip",
                         @"ext": @"zip",
                         @"type": @(WDKMIMETypeZip),
                         @"bytesCount": @50,
                         @"matches": ^BOOL(unsigned char *byteOrder) {
                             const unsigned char bytes1[] = { 0x50, 0x4B };
                             const unsigned char bytes2[] = { 0x3 };
                             const unsigned char bytes3[] = { 0x5 };
                             const unsigned char bytes4[] = { 0x7 };
                             const unsigned char bytes5[] = { 0x4 };
                             const unsigned char bytes6[] = { 0x6 };
                             const unsigned char bytes7[] = { 0x8 };
                             
                             // [0, 1]
                             BOOL b1 = memcmp(byteOrder, bytes1, sizeof(bytes1)) == 0;
                             // [2]
                             BOOL b2 = memcmp(byteOrder + 2, bytes2, sizeof(bytes2)) == 0;
                             // [2]
                             BOOL b3 = memcmp(byteOrder + 2, bytes3, sizeof(bytes3)) == 0;
                             // [2]
                             BOOL b4 = memcmp(byteOrder + 2, bytes4, sizeof(bytes4)) == 0;
                             // [3]
                             BOOL b5 = memcmp(byteOrder + 3, bytes5, sizeof(bytes5)) == 0;
                             // [3]
                             BOOL b6 = memcmp(byteOrder + 3, bytes6, sizeof(bytes6)) == 0;
                             // [3]
                             BOOL b7 = memcmp(byteOrder + 3, bytes7, sizeof(bytes7)) == 0;
                             
                             return b1 && (b2 || b3 || b4) && (b5 || b6 || b7);
                         },
                         },
                 };
    });
    
    return sMap;
}

@end

@implementation WDKDataTool

+ (nullable WDKMIMETypeInfo *)checkMIMETypeWithData:(NSData *)data type:(WDKMIMEType)type {
    if (![data isKindOfClass:[NSData class]]) {
        return nil;
    }
    
    NSDictionary *map = [WDKMIMETypeInfo allSupportMIMETypeInfos];
    NSDictionary *info = map[@(type)];
    if (info) {
        NSInteger byteCount = [info[@"bytesCount"] integerValue];
        BOOL(^block)(unsigned char *) = info[@"matches"];
        
        if (data.length >= byteCount) {
            unsigned char *byteOrder = (unsigned char *)[data bytes];
            if (block && block(byteOrder)) {
                return [WDKMIMETypeInfo infoWithDictionary:info];
            }
        }
    }
    
    return nil;
}

@end
