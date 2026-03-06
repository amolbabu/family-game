import Foundation

/// Result of a card tap operation
/// Provides clear feedback to the UI about what happened
enum TapResult {
    /// Card was successfully revealed; contains the card content
    case revealed(CardContent)
    
    /// Card was already locked and cannot be tapped
    case locked(message: String)
    
    /// Invalid operation; contains error description
    case invalid(error: String)
    
    /// Card was hidden (tapped while revealed)
    case hidden
}
