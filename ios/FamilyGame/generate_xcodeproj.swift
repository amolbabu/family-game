#!/usr/bin/env swift

import Foundation

// Minimal xcodeproj generation script
// This creates the essential project structure Xcode needs

let projectName = "FamilyGame"
let projPath = "\(projectName).xcodeproj"
let pbxprojPath = "\(projPath)/project.pbxproj"

// Create project directory
try? FileManager.default.createDirectory(atPath: projPath, withIntermediateDirectories: true)

// Create minimal pbxproj file (Xcode format)
let pbxproj = """
// !$*UTF8*$!
{
  archiveVersion = 1;
  classes = {};
  objectVersion = 60;
  objects = {
    /* Begin PBXFileReference section */
    1 /* FamilyGameApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "App/FamilyGameApp.swift"; sourceTree = SOURCE_ROOT; };
    2 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = SOURCE_ROOT; };
    /* End PBXFileReference section */
    
    /* Begin PBXGroup section */
    ROOT /* \(projectName) */ = {
      isa = PBXGroup;
      children = (1, 2);
      sourceTree = "<group>";
    };
    /* End PBXGroup section */
    
    /* Begin PBXNativeTarget section */
    TARGET_DEBUG = {
      isa = PBXNativeTarget;
      name = \(projectName);
      productName = \(projectName);
      productType = "com.apple.product-type.application";
    };
    /* End PBXNativeTarget section */
    
    /* Begin PBXProject section */
    PROJECT = {
      isa = PBXProject;
      attributes = {};
      buildConfigurationList = CONFIGS;
      compatibilityVersion = "Xcode 14.0";
      developmentRegion = en;
      hasScannedForEncodings = 0;
      knownRegions = (en);
      mainGroup = ROOT;
      productRefGroup = ROOT;
      projectDirPath = "";
      targets = (TARGET_DEBUG);
    };
    /* End PBXProject section */
    
    /* Begin XCBuildConfiguration section */
    DEBUG = {
      isa = XCBuildConfiguration;
      buildSettings = {
        PRODUCT_NAME = \(projectName);
        SWIFT_VERSION = 5.9;
      };
      name = Debug;
    };
    /* End XCBuildConfiguration section */
    
    /* Begin XCConfigurationList section */
    CONFIGS /* Build configuration list */ = {
      isa = XCConfigurationList;
      buildConfigurations = (DEBUG);
      defaultConfigurationIsVisible = 0;
      defaultConfigurationName = Debug;
    };
    /* End XCConfigurationList section */
  };
  rootObject = PROJECT;
  rootPath = "";
  version = 0;
}
"""

try pbxproj.write(toFile: pbxprojPath, atomically: true, encoding: .utf8)
print("✅ Created \(pbxprojPath)")
