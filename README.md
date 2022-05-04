<p align="center">
  <img src="https://github.com/tannermeade/data-migrator/blob/master/.github/assets/data_migrator.svg?raw=true" height="128">
  <h1 align="center">DataMigrator</h1>
  <p align="center">🚧 Alpha version - Use with care. 🚧</p>
</p>


## Features

- 💎 **The Rosetta Stone for Data**. Convert data schemas with ease
- 🚀 **Portable Data**. Move data from Anywhere. *starting with CSV & Appwrite*
- 🧑‍💻 **Multiplatform**. macOS, Linux, and Windows
- ⏱ **Asynchronous**. A parallel data pipeline
- 🍭 **Feature rich**. Type conversion adapters, create & edit schemas, upload data etc
- 🤲 **Open source**. Everything is open source and free forever!

DataMigrator can do much more (and we are just getting started)

If you want to say thank you, star us on GitHub  🙌💙

<img src="https://github.com/tannermeade/data-migrator/blob/master/.github/assets/data_migrator-screenshot.png?raw=true" height="600">

## Quickstart

The purpose of DataMigrator is to provide a universal translator for data by being portable, diverse, and efficient in migrating and converting data across discrete schemas.

Right now, it is only developed against macOS (Windows and Linux will be officially developed against soon). It shouldn't be too hard to get it running on those targets though.

To get it running on macOS, [install Flutter](https://docs.flutter.dev/get-started/install/macos "install Flutter") and make sure to add the flutter tool to your path.

Then make sure to run `flutter config --enable-macos-desktop ` to enable the macOS target.

Clone this repo, navigate to the directory in terminal, and execute `flutter run`. Choose macOS for the target if it prompts you.

## Architecture


DataMigrator provides powerful and flexible tooling in the form of 3 categories of code:
1. Schema Representation
2. A Conversion Pipeline
3. Diverse Toolchain of Data Origins

#### Schema Representation

DataMigrator represents schemas in a flexible manner that supports flat schema data stores like tabular data (csv & sql) and schema-less deep data stores like JSON.

<img src="https://github.com/tannermeade/data-migrator/blob/master/.github/assets/schema_representation.png?raw=true" height="600">

#### A Conversion Pipeline

The conversion pipeline is meant to be asyncronous as it handles packets of data that are streamed through the conversion type adapters. DataMigrator is built to have a diverse and extendable toolchain of adapters to convert any data type to another.

It is even designed to handle source fields that can hold several data types being converted to a destination with several completely different data types. It handles this by generating, creating, and editing the conversion type adapters where you can define exactly what source data type gets converted to which destination data type for each individual field.

<img src="https://github.com/tannermeade/data-migrator/blob/master/.github/assets/conversion_pipeline.png?raw=true" height="300">

#### Diverse Toolchain of Data Origins

DataMigrator uses adapters called `DataOrigin`s that handle all the responsibilities of the source and destination of the data. The provide configuration, data stream, data sink, and schema validation interfaces.

For `DataOrigin`s that involve schema-less data stores, they are responsible for generating a schema for the data. In the case of CSV tabular data, the data types are not stored in the built-in schema, so the CSV `DataOrigin` will scan the data to generate the data types that fit in each field.

Right now, DataMigrator is focusing on developing the CSV and Appwrite `DataOrigin`s. After the main features have been built out and tested, the next `DataOrigin` will be Firebase.

### License

```
Copyright 2022 Tanner Meade

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
