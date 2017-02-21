

/**  
 openssl genrsa -out private_key.pem 1024
 
 openssl req -new -key private_key.pem -out rsaCertReq.csr
 
 openssl x509 -req -days 3650 -in rsaCertReq.csr -signkey private_key.pem -out rsaCert.crt
 
 openssl x509 -outform der -in rsaCert.crt -out public_key.der　　　　　　　　　　　　　　　// Create public_key.der For IOS
 
 openssl pkcs12 -export -out private_key.p12 -inkey private_key.pem -in rsaCert.crt　　// Create private_key.p12 For IOS. 这一步，请记住你输入的密码，IOS代码里会用到
 
 openssl rsa -in private_key.pem -out rsa_public_key.pem -pubout　　　　　　　　　　　　　// Create rsa_public_key.pem For Java
 　
 openssl pkcs8 -topk8 -in private_key.pem -out pkcs8_private_key.pem -nocrypt　　　　　// Create pkcs8_private_key.pem For Java 
 
 
 上面七个步骤，总共生成7个文件。其中　public_key.der 和 private_key.p12 这对公钥私钥是给IOS用的， rsa_public_key.pem 和 pkcs8_private_key.pem　是给JAVA用的。
 　　它们的源都来自一个私钥：private_key.pem ， 所以IOS端加密的数据，是可以被JAVA端解密的，反过来也一样
 */

extern NSString* const WKRSAPublicKey;
extern NSString* const WKRSAPrivateKey;

#import <Foundation/Foundation.h>

//#define kRSAPublicKey @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1EDFARFM2W/qQNgTX9oc1ZTML\nPu+csNX7WoAwShZc+KlArWQGybwqEKUhrfvyuNYAb4GmnhM7PENh4cjX+g7APjDz\nmyj6Dn7meh7rk14AKi9kWZsn+R+EOB4RSK8c7wAtzcLL9NmOmFokU/7tTgG9MxfP\n0sJCYlpu6ahIbRiZzQIDAQAB\n-----END PUBLIC KEY-----"

@interface LJRSA : NSObject

/**
 *  根据公钥加密字符串
 *
 *  @param str    待加密的字符串
 *  @param pubKey 公钥
 *
 *  @return base64 encoded string
 */
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;

/**  根据公钥加密二进制数据 */
+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;



/**  解密 base64 的字符串，用公钥 */
+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)pubKey;

/**  解密 二进制数据， 用公钥 */
+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey;



/**  解密 base64 的字符串， 用私钥 */
+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;

/**  解密 二进制数据， 用私钥 */
+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey;

@end
