/**
 * @file get_nasm_tool_test.cc
 * @brief A test binary for ensuring nasm binaries are executable on teh current
 * platform.
 */

#include <array>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>

#include "rules_cc/cc/runfiles/runfiles.h"

using rules_cc::cc::runfiles::Runfiles;

// Add support for Bazel 7
#ifndef BAZEL_CURRENT_REPOSITORY
#define BAZEL_CURRENT_REPOSITORY "_main"
#endif

#ifdef _WIN32
#define popen _popen
#define pclose _pclose
#endif

/**
 * @brief Execute a subcommand and capture the output to a string.
 *
 * @param cmd The command to execute
 * @param output The string to write results to
 * @return True if the command exited cleanly
 */
bool exec_command(const std::string& cmd, std::string& output) {
    std::array<char, 128> buffer;

    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd.c_str(), "r"),
                                                  pclose);
    if (!pipe) {
        std::cerr << "popen() failed!" << std::endl;
        return false;
    }

    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
        output += buffer.data();
    }

    return true;
}

int main() {
    const char* nasm_env = std::getenv("NASM");
    if (!nasm_env) {
        std::cerr << "Error locating NASM environment variable" << std::endl;
        return 1;
    }

    std::string error = {};
    std::unique_ptr<Runfiles> runfiles(
        Runfiles::CreateForTest(BAZEL_CURRENT_REPOSITORY, &error));

    if (!error.empty()) {
        std::cerr << "Error creating runfiles: " << error << std::endl;
        return 1;
    }

    const std::string nasm_path = runfiles->Rlocation(nasm_env);
    if (nasm_path.empty()) {
        std::cerr << "Failed to locate runfile: " << nasm_env << std::endl;
        return 1;
    }

    std::string output = {};
    const std::string cmd = nasm_path + " -v";
    if (!exec_command(cmd, output)) {
        return 1;
    }

    if (output.find("NASM") == std::string::npos) {
        std::cerr << "Could not execute " << nasm_env << std::endl;
        return 1;
    }

    return 0;
}
