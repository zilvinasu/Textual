/* ********************************************************************* 
                  _____         _               _
                 |_   _|____  _| |_ _   _  __ _| |
                   | |/ _ \ \/ / __| | | |/ _` | |
                   | |  __/>  <| |_| |_| | (_| | |
                   |_|\___/_/\_\\__|\__,_|\__,_|_|

 Copyright (c) 2010 - 2017 Codeux Software, LLC & respective contributors.
        Please see Acknowledgements.pdf for additional information.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Textual and/or "Codeux Software, LLC", nor the 
      names of its contributors may be used to endorse or promote products 
      derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.

 *********************************************************************** */

NS_ASSUME_NONNULL_BEGIN

#define _availabilityCheckInterval        172800 // 2 days

#if TEXTUAL_BUILT_WITH_PAID_UPGRADE_DIALOG == 1
@interface TDCLicenseUpgradeDialog ()
#if TEXTUAL_BUILT_WITH_LICENSE_MANAGER == 1
@property (nonatomic, copy, readwrite) NSString *licenseKey;
@property (nonatomic, assign, readwrite) TLOLicenseUpgradeEligibility eligibility;
@property (nonatomic, strong, nullable) TDCLicenseUpgradeEligibilitySheet *eligiblitySheet;
#endif

#if TEXTUAL_BUILT_WITH_LICENSE_MANAGER == 0
@property (nonatomic, strong) IBOutlet NSWindow *macAppStoreChoiceSheet;

- (IBAction)macAppStoreChoiceActionDownload:(id)sender;
- (IBAction)macAppStoreChoiceActionClose:(id)sender;
#endif

- (IBAction)availabilityActionLearnMore:(id)sender;
- (IBAction)availabilityActionPurchaseUpgrade:(id)sender;
- (IBAction)availabilityActionDownloadTrial:(id)sender;
- (IBAction)availabilityActionRemindMeLater:(id)sender;
- (IBAction)availabilityActionRemindMeNever:(id)sender;
@end

@implementation TDCLicenseUpgradeDialog

- (instancetype)init
{
    if ((self = [super init])) {
        [self prepareInitialState];

        return self;
    }

    return nil;
}

- (void)prepareInitialState
{
	[RZMainBundle() loadNibNamed:@"TDCLicenseUpgradeDialog" owner:self topLevelObjects:nil];

#if TEXTUAL_BUILT_WITH_LICENSE_MANAGER == 1
	self.eligibility = TLOLicenseUpgradeEligibilityUnknown;
#endif

	[self availabilityPerformCheck];
}

#pragma mark -
#pragma mark Common Actions

- (void)commonActionLearnMore
{
	NSURL *urlToOpen = [NSURL URLWithString:@"https://www.codeux.com/textual/version-7-upgrade/learnMore"];

	[[NSWorkspace sharedWorkspace] openURL:urlToOpen];
}

#if TEXTUAL_BUILT_WITH_LICENSE_MANAGER == 1
- (void)commonActionPurchaseUpgrade
{
	NSString *licenseKey = self.licenseKey;

	if (licenseKey == nil) {
		return;
	}

	NSString *linkToOpen = [NSString stringWithFormat:@"https://www.codeux.com/textual/version-7-upgrade/upgradeLicense/%@", licenseKey];

	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:linkToOpen]];
}

- (void)commonActionDownloadTrial
{
	NSURL *urlToOpen = [NSURL URLWithString:@"https://www.codeux.com/textual/version-7-upgrade/download"];

	[[NSWorkspace sharedWorkspace] openURL:urlToOpen];
}

- (void)commonActionOpenStandaloneStore
{
	NSURL *urlToOpen = [NSURL URLWithString:@"https://www.codeux.com/textual/version-7-upgrade/openStandaloneStore"];

	[[NSWorkspace sharedWorkspace] openURL:urlToOpen];
}
#endif

- (void)commonActionOpenMacAppStore
{
	NSURL *urlToOpen = [NSURL URLWithString:@"https://www.codeux.com/textual/version-7-upgrade/openMacAppStore"];

	[[NSWorkspace sharedWorkspace] openURL:urlToOpen];
}

- (void)commonActionContactSupport
{
	NSURL *urlToOpen = [NSURL URLWithString:@"https://contact.codeux.com/"];

	[[NSWorkspace sharedWorkspace] openURL:urlToOpen];
}

#pragma mark -
#pragma mark Mac App Store Choice Window Actions

#if TEXTUAL_BUILT_WITH_LICENSE_MANAGER == 0

- (void)showMacAppStoreChoiceSheet
{
	[NSApp beginSheet:self.macAppStoreChoiceSheet
	   modalForWindow:self.window
		modalDelegate:self
	   didEndSelector:@selector(macAppStoreChoiceSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (void)closeMacAppStoreChoiceSheet
{
	[NSApp endSheet:self.macAppStoreChoiceSheet];
}

- (void)macAppStoreChoiceSheetDidEnd:(NSWindow *)sender returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[sender close];
}

- (void)macAppStoreChoiceActionDownload:(id)sender
{
	[self commonActionOpenMacAppStore];
}

- (void)macAppStoreChoiceActionClose:(id)sender
{
	[self closeMacAppStoreChoiceSheet];
}
#endif

#pragma mark -
#pragma mark Eligibility Sheet Actions

#if TEXTUAL_BUILT_WITH_LICENSE_MANAGER == 1
- (void)checkEligiblity
{
	if (self.eligiblitySheet != nil) {
		return;
	}

	TDCLicenseUpgradeEligibilitySheet *eligibilitySheet =
	[[TDCLicenseUpgradeEligibilitySheet alloc] initWithLicenseKey:self.licenseKey];

	eligibilitySheet.delegate = self;

	eligibilitySheet.window = self.window;

	[eligibilitySheet checkEligibility];

	self.eligiblitySheet = eligibilitySheet;
}

- (void)closeEligibilitySheet
{
	if (self.eligiblitySheet) {
		[self.eligiblitySheet endSheet];
	}
}

- (void)upgradeEligibilitySheetContactSupport:(TDCLicenseUpgradeEligibilitySheet *)sender
{
	[self commonActionContactSupport];
}

- (void)upgradeEligibilitySheetDownloadTrial:(TDCLicenseUpgradeEligibilitySheet *)sender
{
	[self commonActionDownloadTrial];
}

- (void)upgradeEligibilitySheetPurchaseUpgrade:(TDCLicenseUpgradeEligibilitySheet *)sender
{
	[self commonActionPurchaseUpgrade];
}

- (void)upgradeEligibilitySheetPurchaseMacAppStore:(TDCLicenseUpgradeEligibilitySheet *)sender
{
	[self commonActionOpenMacAppStore];
}

- (void)upgradeEligibilitySheetPurchaseStandalone:(TDCLicenseUpgradeEligibilitySheet *)sender
{
	[self commonActionOpenStandaloneStore];
}

- (void)upgradeEligibilitySheetChanged:(TDCLicenseUpgradeEligibilitySheet *)sender
{
	self.eligibility = sender.eligibility;

	[self saveEligibility];
}

- (void)upgradeEligibilitySheetWillClose:(TDCLicenseUpgradeEligibilitySheet *)sender
{
	self.eligiblitySheet = nil;
}

- (void)saveEligibility
{
	/* These values are read by Textual 7 when launching. Not this dialog. */
	[RZUserDefaults() setUnsignedInteger:self.eligibility forKey:@"Textual 7 Upgrade -> Tv7 -> Eligibility"];

	[RZUserDefaults() setObject:self.licenseKey forKey:@"Textual 7 Upgrade -> Tv7 -> Eligible License Key"];

	[RZUserDefaults() synchronize];
}
#endif

#pragma mark -
#pragma mark Availability Check

- (void)showAvailabilityDialogNextLaunch
{
	[RZUserDefaults() setBool:YES forKey:@"Textual 7 Upgrade -> Tv6 -> Show Upgrade Dialog Next Launch"];
    
    [RZUserDefaults() synchronize];
}

- (void)availabilityPerformCheck
{
    LogToConsoleInfo("Availability perform check enter")

	BOOL neverShowDialog = [RZUserDefaults() boolForKey:@"Textual 7 Upgrade -> Tv6 -> Never Show Upgrade Dialog"];

	if (neverShowDialog) {
        LogToConsoleInfo("User configured dialog to never be shown again")
        
		return;
	}

	BOOL showDialogForced = [RZUserDefaults() boolForKey:@"Textual 7 Upgrade -> Tv6 -> Show Upgrade Dialog Next Launch"];

	if (showDialogForced) {
        LogToConsoleInfo("Dialog configured to appear regardless of availability")

		[RZUserDefaults() removeObjectForKey:@"Textual 7 Upgrade -> Tv6 -> Show Upgrade Dialog Next Launch"];

		[self show];

		return;
	}

	NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];

	if ([TDCLicenseUpgradeDialog isAvailableDate:currentTime] == NO) {
		LogToConsoleInfo("Not presenting dialog because of date")

		return;
	}

	BOOL remindMeLater = [RZUserDefaults() boolForKey:@"Textual 7 Upgrade -> Tv6 -> Remind Me Later"];

	NSTimeInterval lastCheckTime = [RZUserDefaults() doubleForKey:@"Textual 7 Upgrade -> Tv6 -> Availability Dialog Last Presentation"];

	if (lastCheckTime > 0 && remindMeLater) {
		if ((currentTime - lastCheckTime) < _availabilityCheckInterval) {
            LogToConsoleInfo("Not enough time has passed since last check")

			return;
		}
	}

	[RZUserDefaults() setDouble:currentTime forKey:@"Textual 7 Upgrade -> Tv6 -> Availability Dialog Last Presentation"];

	[RZUserDefaults() removeObjectForKey:@"Textual 7 Upgrade -> Tv6 -> Remind Me Later"];

	[self show];
}

+ (BOOL)isAvailableDate:(NSTimeInterval)date
{
	if (date < 1503100800 || // August 19, 2017
		date > 1569888000) 	// October 2019
	{
		return NO;
	}

	return YES;
}

#pragma mark -
#pragma mark Availability Check Window Actions

- (void)show
{
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        [self.window setLevel:NSFloatingWindowLevel];
    });

	[super show];
}

- (void)resetAvailabilityWindowLevel
{
    [self.window setLevel:NSNormalWindowLevel];
}

- (void)availabilityActionLearnMore:(id)sender
{
    [self resetAvailabilityWindowLevel];

	[self commonActionLearnMore];
}

- (void)availabilityActionDownloadTrial:(id)sender
{
    [self resetAvailabilityWindowLevel];

#if TEXTUAL_BUILT_WITH_LICENSE_MANAGER == 1
	[self commonActionDownloadTrial];
#else
	[self commonActionOpenMacAppStore];
#endif
}

- (void)availabilityActionPurchaseUpgrade:(id)sender
{
    [self resetAvailabilityWindowLevel];

#if TEXTUAL_BUILT_WITH_LICENSE_MANAGER == 1

	NSString *licenseKey = TLOLicenseManagerLicenseKey();

	if (licenseKey == nil) {
		[TLOPopupPrompts sheetWindowWithWindow:self.window
										  body:TXTLS(@"TDCLicenseUpgradeDialog[1001][2]")
										 title:TXTLS(@"TDCLicenseUpgradeDialog[1001][1]")
								 defaultButton:TXTLS(@"Prompts[0005]")
							   alternateButton:nil
								   otherButton:nil];

		return;
	}

	self.licenseKey = licenseKey;

	[self checkEligiblity];

#else

	[self showMacAppStoreChoiceSheet];

#endif

}

- (void)availabilityActionRemindMeLater:(id)sender
{
    [self resetAvailabilityWindowLevel];

	[RZUserDefaults() setBool:YES forKey:@"Textual 7 Upgrade -> Tv6 -> Remind Me Later"];

	[self close];
}

- (void)availabilityActionRemindMeNever:(id)sender
{
    [self resetAvailabilityWindowLevel];

	[RZUserDefaults() setBool:YES forKey:@"Textual 7 Upgrade -> Tv6 -> Never Show Upgrade Dialog"];

	[self close];
}

@end

#endif

NS_ASSUME_NONNULL_END
