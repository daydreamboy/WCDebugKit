//
//  WDKDataTool.h
//  WDKDebugKit
//
//  Created by wesley_chen on 2021/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WDKMIMEType) {
    WDKMIMETypeUnknown,
    WDKMIMETypeAmr,
    WDKMIMETypeAr,
    WDKMIMETypeAvi,
    WDKMIMETypeBmp,
    WDKMIMETypeBz2,
    WDKMIMETypeCab,
    WDKMIMETypeCr2,
    WDKMIMETypeCrx,
    WDKMIMETypeDeb, // Needs to be before `ar` check, because `deb` is kind of `ar`
    WDKMIMETypeDmg,
    WDKMIMETypeEot,
    WDKMIMETypeEpub,
    WDKMIMETypeExe,
    WDKMIMETypeFlac,
    WDKMIMETypeFlif,
    WDKMIMETypeFlv,
    WDKMIMETypeGif,
    WDKMIMETypeGz,
    WDKMIMETypeHeic,
    WDKMIMETypeHeif,
    WDKMIMETypeIco,
    WDKMIMETypeJpg,
    WDKMIMETypeJxr,
    WDKMIMETypeLz,
    WDKMIMETypeM4a,
    WDKMIMETypeM4v,
    WDKMIMETypeMid,
    WDKMIMETypeMkv,
    WDKMIMETypeMov,
    WDKMIMETypeMp3,
    WDKMIMETypeMp4,
    WDKMIMETypeMpg,
    WDKMIMETypeMsi,
    WDKMIMETypeMxf,
    WDKMIMETypeNes,
    WDKMIMETypeOgg,
    WDKMIMETypeOpus, // Needs to be before `ogg` check, because `opus` is kind of `ogg`
    WDKMIMETypeOtf,
    WDKMIMETypePdf,
    WDKMIMETypePng,
    WDKMIMETypePs,
    WDKMIMETypePsd,
    WDKMIMETypeRar,
    WDKMIMETypeRpm,
    WDKMIMETypeRtf,
    WDKMIMEType7z,
    WDKMIMETypeSqlite,
    WDKMIMETypeSwf,
    WDKMIMETypeTar,
    WDKMIMETypeTif,
    WDKMIMETypeTtf,
    WDKMIMETypeWav,
    WDKMIMETypeWebm,
    WDKMIMETypeWebp,
    WDKMIMETypeWmv,
    WDKMIMETypeWoff,
    WDKMIMETypeWoff2,
    WDKMIMETypeXpi, // Needs to be before `zip` check, because `xpi` is kind of `zip`. And assumes signed .xpi from addons.mozilla.org
    WDKMIMETypeXz,
    WDKMIMETypeZ,
    WDKMIMETypeZip,
};

@interface WDKMIMETypeInfo : NSObject
/// the MIME, e.g. audio/amr
@property (nonatomic, copy) NSString *MIME;
/// file extesion, e.g. amr
@property (nonatomic, copy) NSString *extension;
/// The WDKMIMEType
@property (nonatomic, assign) WDKMIMEType type;
/// the total bytes count of MIME flag
@property (nonatomic, assign) NSUInteger bytesCount;
/// the match block
@property (nonatomic, copy) BOOL (^matchBlock)(unsigned char *byteOrder);

/**
 Get MIME type

 @param type the WDKMIMEType
 @return the WDKMIMETypeInfo object. Return nil if the type not supported.
 */
+ (nullable WDKMIMETypeInfo *)infoWithMIMEType:(WDKMIMEType)type;

@end


@interface WDKDataTool : NSObject

/**
 Check MIME type from data with the specific type

 @param data the NSData
 @param type the WDKMIMEType
 @return the WDKMIMETypeInfo object. Return nil if the data not match the type
 */
+ (nullable WDKMIMETypeInfo *)checkMIMETypeWithData:(NSData *)data type:(WDKMIMEType)type;

@end

NS_ASSUME_NONNULL_END
