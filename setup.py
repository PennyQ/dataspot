import setuptools


with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="dataspot",
    version="0.0.1devl",
    author="Patrick de Hoon",
    author_email="patrickdehoon@gmail.com",
    description="The script analyzer and visualizer",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/patrickdehoon/dataspot",
    packages=setuptools.find_packages(exclude=['snippets', 'venv']),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    license='MIT',
    install_requires=['bokeh', 'click', 'six', 'pyfiglet', 'termcolor'],
    keywords='development database analyze',
    include_package_data=True,
    python_requires='>=3',
    entry_points={
       'console_scripts': [
           'dataspot=dataspot.cli.dataspot_cli:main'
       ],
   },
)