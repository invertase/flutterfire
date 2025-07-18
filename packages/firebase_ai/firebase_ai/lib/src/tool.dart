// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'schema.dart';

/// Tool details that the model may use to generate a response.
///
/// A `Tool` is a piece of code that enables the system to interact with
/// external systems to perform an action, or set of actions, outside of
/// knowledge and scope of the model.
final class Tool {
  // ignore: public_member_api_docs
  Tool._(this._functionDeclarations, this._googleSearch);

  /// Returns a [Tool] instance with list of [FunctionDeclaration].
  static Tool functionDeclarations(
      List<FunctionDeclaration> functionDeclarations) {
    return Tool._(functionDeclarations, null);
  }

  /// Creates a tool that allows the model to use Grounding with Google Search.
  ///
  /// Grounding with Google Search can be used to allow the model to connect to
  /// Google Search to access and incorporate up-to-date information from the
  /// web into it's responses.
  ///
  /// When using this feature, you are required to comply with the
  /// "Grounding with Google Search" usage requirements for your chosen API
  /// provider:
  /// [Gemini Developer API](https://ai.google.dev/gemini-api/terms#grounding-with-google-search)
  /// or Vertex AI Gemini API (see [Service Terms](https://cloud.google.com/terms/service-terms)
  /// section within the Service Specific Terms).
  ///
  /// - [googleSearch]: An empty [GoogleSearch] object. The presence of this
  ///   object in the list of tools enables the model to use Google Search.
  ///
  /// Returns a `Tool` configured for Google Search.
  static Tool googleSearch({GoogleSearch googleSearch = const GoogleSearch()}) {
    return Tool._(null, googleSearch);
  }

  /// A list of `FunctionDeclarations` available to the model that can be used
  /// for function calling.
  ///
  /// The model or system does not execute the function. Instead the defined
  /// function may be returned as a [FunctionCall] with arguments to the client
  /// side for execution. The next conversation turn may contain a
  /// [FunctionResponse]
  /// with the role "function" generation context for the next model turn.
  final List<FunctionDeclaration>? _functionDeclarations;

  /// A tool that allows the generative model to connect to Google Search to
  /// access and incorporate up-to-date information from the web into its
  /// responses.
  final GoogleSearch? _googleSearch;

  /// Convert to json object.
  Map<String, Object> toJson() => {
        if (_functionDeclarations case final _functionDeclarations?)
          'functionDeclarations':
              _functionDeclarations.map((f) => f.toJson()).toList(),
        if (_googleSearch case final _googleSearch?)
          'googleSearch': _googleSearch.toJson()
      };
}

/// A tool that allows the generative model to connect to Google Search to
/// access and incorporate up-to-date information from the web into its
/// responses.
///
/// When using this feature, you are required to comply with the
/// "Grounding with Google Search" usage requirements for your chosen API
/// provider:
/// [Gemini Developer API](https://ai.google.dev/gemini-api/terms#grounding-with-google-search)
/// or Vertex AI Gemini API (see [Service Terms](https://cloud.google.com/terms/service-terms)
/// section within the Service Specific Terms).
final class GoogleSearch {
  // ignore: public_member_api_docs
  const GoogleSearch();

  /// Convert to json object.
  Map<String, Object> toJson() => {};
}

/// Structured representation of a function declaration as defined by the
/// [OpenAPI 3.03 specification](https://spec.openapis.org/oas/v3.0.3).
///
/// Included in this declaration are the function name and parameters. This
/// FunctionDeclaration is a representation of a block of code that can be used
/// as a `Tool` by the model and executed by the client.
final class FunctionDeclaration {
  // ignore: public_member_api_docs
  FunctionDeclaration(this.name, this.description,
      {required Map<String, Schema> parameters,
      List<String> optionalParameters = const []})
      : _schemaObject = Schema.object(
            properties: parameters, optionalProperties: optionalParameters);

  /// The name of the function.
  ///
  /// Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum
  /// length of 63.
  final String name;

  /// A brief description of the function.
  final String description;

  final Schema _schemaObject;

  /// Convert to json object.
  Map<String, Object?> toJson() => {
        'name': name,
        'description': description,
        'parameters': _schemaObject.toJson()
      };
}

/// Config for tools to use with model.
final class ToolConfig {
  // ignore: public_member_api_docs
  ToolConfig({this.functionCallingConfig});

  /// Config for function calling.
  final FunctionCallingConfig? functionCallingConfig;

  /// Convert to json object.
  Map<String, Object?> toJson() => {
        if (functionCallingConfig case final config?)
          'functionCallingConfig': config.toJson(),
      };
}

/// Configuration specifying how the model should use the functions provided as
/// tools.
final class FunctionCallingConfig {
  // ignore: public_member_api_docs
  FunctionCallingConfig._({this.mode, this.allowedFunctionNames});

  /// The mode in which function calling should execute.
  ///
  /// If null, the default behavior will match [FunctionCallingMode.auto].
  final FunctionCallingMode? mode;

  /// A set of function names that, when provided, limits the functions the
  /// model will call.
  ///
  /// This should only be set when the Mode is [FunctionCallingMode.any].
  /// Function names should match [FunctionDeclaration.name]. With mode set to
  /// `any`, model will predict a function call from the set of function names
  /// provided.
  final Set<String>? allowedFunctionNames;

  /// Returns a [FunctionCallingConfig] instance with mode of [FunctionCallingMode.auto].
  static FunctionCallingConfig auto() {
    return FunctionCallingConfig._(mode: FunctionCallingMode.auto);
  }

  /// Returns a [FunctionCallingConfig] instance with mode of [FunctionCallingMode.any].
  static FunctionCallingConfig any(Set<String> allowedFunctionNames) {
    return FunctionCallingConfig._(
        mode: FunctionCallingMode.any,
        allowedFunctionNames: allowedFunctionNames);
  }

  /// Returns a [FunctionCallingConfig] instance with mode of [FunctionCallingMode.none].
  static FunctionCallingConfig none() {
    return FunctionCallingConfig._(mode: FunctionCallingMode.none);
  }

  /// Convert to json object.
  Object toJson() => {
        if (mode case final mode?) 'mode': mode.toJson(),
        if (allowedFunctionNames case final allowedFunctionNames?)
          'allowedFunctionNames': allowedFunctionNames.toList(),
      };
}

/// The mode in which the model should use the functions provided as tools.
enum FunctionCallingMode {
  /// The mode with default model behavior.
  ///
  /// Model decides to predict either a function call or a natural language
  /// response.
  auto,

  /// A mode where the Model is constrained to always predicting a function
  /// call only.
  any,

  /// A mode where the model will not predict any function call.
  ///
  /// Model behavior is same as when not passing any function declarations.
  none;

  /// Convert to json object.
  String toJson() => switch (this) {
        auto => 'AUTO',
        any => 'ANY',
        none => 'NONE',
      };
}
