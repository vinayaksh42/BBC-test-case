#!/bin/bash

# Variables
PROJECT_DIR="./repos/jvm-profiler"
TARGET_CLASS="com.uber.profiling.util.JsonUtils"
TARGET_METHOD="serialize"
EVOSUITE_JAR="../../EvoSuite/evosuite-1.2.0.jar"
EVOSUITE_RUNTIME_JAR="../../EvoSuite/evosuite-standalone-runtime-1.2.0.jar"
SEARCH_BUDGET=60
OUTPUT_DIR="$PROJECT_DIR/generated-tests"
M2_REPO="$HOME/.m2/repository"

# Change to project directory
cd "$PROJECT_DIR" || exit

# Install the project and skip tests
mvn clean install -DskipTests -fn

# Download dependencies
mvn dependency:copy-dependencies

# generate the test cases
java -jar "$EVOSUITE_JAR" -class "$TARGET_CLASS" -projectCP target/classes:$(echo target/dependency/*.jar | tr ' ' ':') -Dtarget_method="$TARGET_METHOD" -Dsearch_budget="$SEARCH_BUDGET"

# compile the generated test cases
javac -cp target/classes:$(echo target/dependency/*.jar | tr ' ' ':'):"$EVOSUITE_RUNTIME_JAR="../../EvoSuite/evosuite-standalone-runtime-1.2.0.jar"
" evosuite-tests/"$TARGET_CLASS"*.java


# Run EvoSuite generated test cases
java -cp target/classes:evosuite-tests:$(echo target/dependency/*.jar | tr ' ' ':'):"$EVOSUITE_RUNTIME_JAR="../../EvoSuite/evosuite-standalone-runtime-1.2.0.jar"
" org.junit.runner.JUnitCore "$TARGET_CLASS"_ESTest