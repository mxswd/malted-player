//
//  ViewController.m
//  Malted Player
//
//  Created by Maxwell on 14/07/20.
//  Copyright © 2020 Maxwell Swadling. All rights reserved.
//

#import "ViewController.h"

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "PasswordSheet.h"

#import <sys/stat.h>

@interface ViewController () <AVAssetResourceLoaderDelegate>

@property NSMutableArray *requests;
@property NSData *decryptedVideo;
@property NSURL *file;

@end

@implementation ViewController {
    FILE *fd;
    size_t fsize;
    size_t startPos;
    NSFileHandle *fh;
    uint8_t key[32];
    uint8_t iv[16];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requests = [NSMutableArray new];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    // FIXME: I should use an NSDocument so that open recent, right click Document Icon, etc. work.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        
        [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == NSFileHandlingPanelOKButton) {
                    self.file = [[panel URLs] objectAtIndex:0];
                    self.view.window.title = self.file.lastPathComponent;
                    PasswordSheet *vc = [[NSStoryboard mainStoryboard] instantiateControllerWithIdentifier:@"PasswordSheet"];
                    vc.delegate = self;
                    [self presentViewControllerAsSheet:vc];
                } else {
                    [self.view.window close];
                }
           });
        }];
    });
    
}

- (void)playFile:(id)sender {
    
    fd = fopen(self.file.fileSystemRepresentation, "r");
    struct stat s;
    fstat(fileno(fd), &s);
    
    // FIXME: error handling everywhere.
    int8_t magic[8];
    fread(magic, sizeof(magic), 1, fd);
    if (memcmp(magic, "Malted__", 8) == 0) {
        
    } else {
        return;
    }
    
    uint8_t salt[8];
    fread(salt, sizeof(salt), 1, fd);
    
    const int   derivedKeySize = kCCKeySizeAES256 + kCCBlockSizeAES128;
    uint8_t     derivedKey[derivedKeySize];
    
    char *password = self.password.UTF8String;
    CCKeyDerivationPBKDF(kCCPBKDF2, password, strlen(password), salt, sizeof(salt), kCCPRFHmacAlgSHA256, 1000000, derivedKey, derivedKeySize);

    memcpy(key, derivedKey, 32);
    memcpy(iv, derivedKey + 32, 16);
    
    fh = [[NSFileHandle alloc] initWithFileDescriptor:fileno(self->fd)];
    startPos = ftell(fd);
    fsize = s.st_size - startPos;
    
    NSURL *url = [NSURL URLWithString:@"https-donotload://localhost"];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    self.avPlayer.player = [[AVPlayer alloc] initWithPlayerItem:item];
    
}

- (void)viewDidDisappear {
    [super viewDidDisappear];
    fclose(fd);
//    [self.avPlayer.player pause];
//    self.avPlayer.player = nil;
    [self.avPlayer.player replaceCurrentItemWithPlayerItem:nil];
    self.decryptedVideo = nil;
    self.avPlayer = nil;
    
}


- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    [self.requests addObject:loadingRequest];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (self.decryptedVideo == nil) {
            size_t bytesOutCount;
            [self->fh seekToFileOffset:0 + self->startPos];
            NSMutableData *videoBytes = [NSMutableData dataWithData:[NSData dataWithData:[self->fh readDataToEndOfFile]]];
            CCCryptorRef cc;
            CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding, self->key, kCCKeySizeAES256, self->iv, &cc);
            CCCryptorStatus status = CCCryptorUpdate(cc, videoBytes.bytes, videoBytes.length, videoBytes.mutableBytes, videoBytes.length, &bytesOutCount);
            // FIXME: didn't do a CC Cryptor Final.
            if (status == kCCSuccess) {
                self.decryptedVideo = [NSData dataWithData:videoBytes];
            }
            CCCryptorRelease(cc);
        }
        
        [loadingRequest.contentInformationRequest setByteRangeAccessSupported:YES];
        [loadingRequest.contentInformationRequest setContentType:@"com.apple.m4v-video"];
        [loadingRequest.contentInformationRequest setContentLength:self.decryptedVideo.length];
        
        AVAssetResourceLoadingDataRequest *dataRequest = loadingRequest.dataRequest;
        int64_t start;
        
        if (dataRequest.currentOffset == 0) {
            start = dataRequest.requestedOffset;
        } else {
            start = dataRequest.currentOffset;
        }
        
        int64_t tosend = dataRequest.requestedLength;
        [[loadingRequest dataRequest] respondWithData:[self.decryptedVideo subdataWithRange:NSMakeRange(start, tosend)]];
        [loadingRequest finishLoading];
        [self.requests removeObject:loadingRequest];
        
    });
    return true;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requests removeObject:loadingRequest];
}




@end
