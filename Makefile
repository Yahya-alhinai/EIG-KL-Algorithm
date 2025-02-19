## Check if CONDA_PREFIX is set
ifndef CONDA_PREFIX
$(error CONDA_PREFIX is not set. Please activate your conda environment first: conda activate KL)
endif


## Compiler and flags
CXX = g++
NVCC = nvcc
CXXFLAGS = -std=c++17 -O3 -Wall -Wextra \
           -I$(CONDA_PREFIX)/include \
           -I$(CONDA_PREFIX)/include/eigen3 \
           -fopenmp
NVCCFLAGS = -O3 -arch=sm_90 -Xcompiler -fopenmp -use_fast_math -extended-lambda


## Libraries
LIBS = -L$(CONDA_PREFIX)/lib -llapack -lblas -llapacke


## Output directories
DIRS = results


## Targets
.PHONY: all clean check_env cKL cEIG gKL


## Default target
all: check_env cEIG cKL gKL


## Check conda environment
check_env:
	@if [ -z "$$CONDA_PREFIX" ]; then \
		echo "Error: CONDA_PREFIX is not set. Please activate your conda environment."; \
		exit 1; \
	fi
	@if [ ! -d "$(CONDA_PREFIX)/include/eigen3" ]; then \
		echo "Error: Eigen3 not found. Please install required dependencies."; \
		echo "Run: conda install -c conda-forge eigen"; \
		exit 1; \
	fi
	@if [ ! -d "$(CONDA_PREFIX)/include/Spectra" ]; then \
		echo "Error: Spectra not found. Please install Spectra library."; \
		echo "See README.md for installation instructions."; \
		exit 1; \
	fi


## Compile EIG executable
cEIG: cEIG.cpp
	@echo "Building EIG:" 
	rm -f cEIG
	$(CXX) $(CXXFLAGS) $< -o $@ $(LIBS)
	@echo


## Compile KL executable
cKL: cKL.cpp
	@echo "Building KL:"
	rm -f cKL
	$(CXX) $(CXXFLAGS) $< -o $@ $(LIBS)
	@echo


## Compile gKL executable
gKL: gKL.cu
	@echo "Building gKL:"
	rm -f gKL
	$(NVCC) $(NVCCFLAGS) $< -o $@
	@echo


## Clean target
clean_binary:
	rm -f cEIG cKL gKL


clean: clean_binary
	rm -rf $(DIRS)