#import <MPDisplayMgr.h>
#import <MPDisplay.h>
#import <MPDisplayPreset.h>
#include <stdio.h>

CFDictionaryRef SLSDisplayCopyPresetData(int displayID, int presetIndex);
void SLSDisplaySetPresetData(int displayID, int presetIndex, CFDictionaryRef ref);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
		printf("NOTE: this software has only been tested on built in MacBook Pro XDR displays. Any damage caused as a result of this program is not the responsibility of the program author.\n");

		MPDisplayMgr* m = [[MPDisplayMgr alloc] init];

		if(!m) {
			printf("ERROR: Failed to intiialise display manager\n");
			return -1;
		}

		NSArray* displays = m.displays;

		printf("Please select a display (should be your built in display):\n");
		int i = 0;
		for(MPDisplay* display in displays) {
			printf("\t%d: %s\n", i, [display.displayName UTF8String]);
			i += 1;
		}

		int displayIndex = -1;
		while(displayIndex < 0 || displayIndex >= [displays count]) {
			printf("Please choose a display: ");
			scanf("%d", &displayIndex);
		}

		MPDisplay* builtinDisplay = (MPDisplay*)displays[displayIndex];

		printf("Getting default preset data...\n");

		NSMutableDictionary* presetDictionary = [builtinDisplay.defaultPreset.presetDictionary mutableCopy];
		if(!presetDictionary) {
			printf("ERROR: Failed to get preset dictionary\n");
			return -1;
		}

		/* First we build a preset and set the max brightness to XDR levels */

		printf("Updating data...\n");
		[presetDictionary setObject:@1600 forKey: @"PresetMaxSDRLuminance"];
		[presetDictionary setObject:@1600 forKey: @"PresetHostMaxSliderBrightness"];
		[presetDictionary setObject:@"Apple XDR Display (Full Brightness)" forKey: @"PresetName"];
		[presetDictionary setObject:@"Allows you to use the full brightness of your built in display, without watching HDR content." forKey: @"PresetDescription"];

		printf("Finding next blank preset...\n");

		MPDisplayPreset* customPreset = NULL;
		for(MPDisplayPreset* p in builtinDisplay.presets) {
			if(!p.isValid && p.isWritable) {
				customPreset = p;
				break;
			}
		}
		if(customPreset == NULL) {
			printf("ERROR: no empty presets available. Failing\n");
			return -1;
		}

		printf("Initialising preset %llu...\n", customPreset.presetIndex);

		[customPreset makeValidWithSettings:presetDictionary];


		printf("Unlocking preset...\n");

		/* Then we unlock it with SLS. */


		/* Get the preset data from SLS */
		CFDictionaryRef presetData = SLSDisplayCopyPresetData(builtinDisplay.displayID, customPreset.presetIndex);
		if(!presetData) {
			printf("ERROR: Failed to get preset data from SLS\n");
			return -1;
		}


        NSMutableDictionary* slsPresetDictionary = [(__bridge NSDictionary*)presetData mutableCopy];

        /* Allow nightshift, truetone, brightness control etc. */
		[slsPresetDictionary setObject:@0 forKey: @"PresetHostDisableAutoBlackLevel"];
		[slsPresetDictionary setObject:@0 forKey: @"PresetHostDisableAutoBrightness"];
		[slsPresetDictionary setObject:@0 forKey: @"PresetHostDisableEDR"];
		[slsPresetDictionary setObject:@0 forKey: @"PresetHostDisableNightShift"];
		[slsPresetDictionary setObject:@0 forKey: @"PresetHostDisableHarmony"];
		[slsPresetDictionary setObject:@0 forKey: @"PresetSRGB"];
		[slsPresetDictionary setObject:@0 forKey: @"PresetHostReferenceColor"];
		[slsPresetDictionary setObject:@4 forKey: @"PresetHostMinSliderBrightness"];


		printf("Pushing unlock and activating preset...\n");
		SLSDisplaySetPresetData(builtinDisplay.displayID, customPreset.presetIndex, (__bridge CFDictionaryRef)slsPresetDictionary);


		printf("DONE! You should now have a fully unlocked preset, which allows you to use the full brightness of your display\n");

	}
    return 0;
}