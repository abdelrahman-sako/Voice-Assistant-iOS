//
//  FrameworkLocalizationManager.swift
//  VoiceAssistant
//
//  Created by Yazan Kareem on 28/01/2026.
//


public final class FrameworkLocalizationManager {

    public static let shared = FrameworkLocalizationManager()

    private(set) var language: String = "en"

    private init() {}

    /// Call this from the MAIN APP
    public func setLanguage(_ language: String) {
        self.language = language
    }
}