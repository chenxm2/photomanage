//
//  DefineHeader.h
//  photomanage
//
//  Created by chenxianming on 2024/9/14.
//

#ifndef DefineHeader_h
#define DefineHeader_h

#define WEAK_SELF __weak typeof(self) weakSelf = self;
#define STRONG_SELF __strong typeof(weakSelf) strongSelf = weakSelf;

#endif /* DefineHeader_h */
