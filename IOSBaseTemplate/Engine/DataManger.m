//
//  DataManger.m
//  IOSBaseTemplate
//
//  Created by WYStudio on 21/2/22.
//  Copyright (c) 2021年 WYStudio. All rights reserved.
//

#import "DataManger.h"
#import <Contacts/CNContact.h>
#import <Contacts/CNContactStore.h>
#import <Contacts/CNContact+Predicates.h>
#import <Contacts/CNContactFetchRequest.h>
#import <Contacts/CNSaveRequest.h>

@interface DataManger ()

@property (nonatomic, strong) EKEventStore *scheduleStore;
@property (nonatomic, strong) CNContactStore *contactStore;


@end

//--------------------------------------------------------------------
@implementation DataManger

+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    static DataManger *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[DataManger alloc] init];
    });
    return sharedInstance;
}

#pragma 日程
-(void)getScheduleEvent:(void (^)(NSArray *eventArray))completion {
    if(nil == self.scheduleStore) {
        self.scheduleStore = [[EKEventStore alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [_scheduleStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if(nil == strongSelf || NO == granted) {
            completion(nil);
            return;
        }
    
        NSArray *events = [NSArray array];
        NSArray *calendarsArray = [strongSelf.scheduleStore calendarsForEntityType:EKEntityTypeEvent];
        for (int i = 0; i < calendarsArray.count; i++) {
            EKCalendar *temp = calendarsArray[i];
            if (NO == [temp.title isEqual:@"Calendar"] && NO == [temp.title isEqual:@"日历"]) {
                continue;
            }
            
            NSDate *endTime = [[NSDate alloc] init];
            NSDate *startTime = [strongSelf getPriousorLaterDateFromDate:endTime withMonth:-(12 * 4)];
            NSPredicate *predicate = [strongSelf.scheduleStore predicateForEventsWithStartDate:startTime endDate:endTime calendars:[NSArray arrayWithObject:temp]];
            events = [strongSelf.scheduleStore eventsMatchingPredicate:predicate];
            break;
        }
        
        completion(events);
    }];
}

- (NSDate*)getPriousorLaterDateFromDate:(NSDate*)date withMonth:(int)month{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];// NSGregorianCalendar
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    return mDate;

}

-(BOOL)deleteEvent:(EKEvent *)event {
    [event setCalendar:[self.scheduleStore defaultCalendarForNewEvents]];
    
    NSError *err;
    [self.scheduleStore removeEvent:event span:EKSpanThisEvent commit:YES error:&err];
    return err == nil;
}

#pragma 通讯录

-(void)getContactData:(void (^)(NSArray *contactList))completion {
    if(nil == self.contactStore) {
        self.contactStore = [CNContactStore new];
    }
    
    __weak typeof(self) weakSelf = self;
    [_contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if(nil == strongSelf || NO == granted) {
            completion(nil);
            return;
        }
        
        //获取通讯录中所有的联系人
        NSMutableArray *contactList = [NSMutableArray array];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey]];
        [strongSelf.contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            // 获取姓名
            NSString *name = [NSString stringWithFormat:@"%@%@", contact.familyName, contact.givenName];
            // 获取电话号码
            NSMutableArray *phoneArray = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.phoneNumbers){
                 CNPhoneNumber *phoneValue = labeledValue.value;
                [phoneArray addObject:phoneValue.stringValue];
            }
            
            [contactList addObject:@{@"name":name, @"phoneArray":phoneArray}];
        }];
        
        completion(contactList);
    }];
}

//- (void)kk {
//    CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
//        CNContactStore * store = [[CNContactStore alloc]init];
//
//        NSArray*  arrFetchedcontact = nil;
//        @try {
//
//            NSError * err = nil;
//            NSArray * keytoFetch = @[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
//            NSPredicate * predicate = [CNContact predicateForContactsMatchingName:@""];
//            arrFetchedcontact = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keytoFetch error:&err];
//        }
//        @catch (NSException *exception) {
//            NSLog(@"description = %@",[exception description]);
//        }
//
//        if([arrFetchedcontact count] > 0)
//        {
//
//            NSLog(@"ArrFetchedContact %@",arrFetchedcontact);
//
//
//            CNMutableContact * contactToUpdate = [[arrFetchedcontact objectAtIndex:0] mutableCopy];
//            NSMutableArray * arrNumbers = [[contactToUpdate phoneNumbers] mutableCopy];
//            [arrNumbers removeObjectAtIndex:0];
//
//            CNLabeledValue * homePhone = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:FieldNumbers]];
//
//            NSLog(@"Print Homephone %@",homePhone);
//
//
//            [arrNumbers addObject:homePhone];
//            [contactToUpdate setPhoneNumbers:arrNumbers];
//
//            [saveRequest updateContact:contactToUpdate];
//
//            @try {
//
//                NSLog(@"Success %d",[store executeSaveRequest:saveRequest error:nil]);
//
//
//            }
//            @catch (NSException *exception) {
//                NSLog(@"description = %@",[exception description]);
//            }
//        }
//}


@end