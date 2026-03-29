from setuptools import setup, find_packages

setup(
    name='docassemble.yourlegalaid',
    version='1.0.0',
    description='YourLegalAid.ca - Ontario LTB Document Automation',
    long_description='Automated legal document generation for Ontario Landlord and Tenant Board forms.',
    author='YourLegalAid',
    author_email='support@yourlegalaid.ca',
    license='MIT',
    url='https://yourlegalaid.ca',
    packages=find_packages(),
    namespace_packages=['docassemble'],
    install_requires=[],
    zip_safe=False,
    package_data={
        'docassemble.yourlegalaid': [
            'data/questions/*',
            'data/templates/*',
            'data/static/*',
        ],
    },
)
