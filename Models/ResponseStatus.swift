public enum ResponseStatus: String, Decodable {
    case ok
    case internalError = "interrnal-error"
}
