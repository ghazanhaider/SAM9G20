#include <SerialPort.h>
#include <SerialStream.h>

using namespace LibSerial ;

// Create and open the serial port for communication.
SerialPort   my_serial_port( "/dev/ttyS0" );
SerialStream my_serial_stream( "/dev/ttyUSB0" ) ;


// Create a object instance.
SerialPort   my_serial_port;
SerialStream my_serial_stream;

// Obtain the serial port name from user input.
std::cout << "Please enter the name of the serial device, (e.g. /dev/ttyUSB0): " << std::flush;
std::string serial_port_name;
std::cin >> serial_port_name;

// Open the serial port for communication.
my_serial_port.Open( serial_port_name );
my_serial_stream.Open( serial_port_name );


// Set the desired baud rate using a SetBaudRate() method call.
// Available baud rate values are defined in SerialStreamConstants.h.

my_serial_port.SetBaudRate( BAUD_115200 );
my_serial_stream.SetBaudRate( BAUD_115200 );

// Set the desired character size using a SetCharacterSize() method call.
// Available character size values are defined in SerialStreamConstants.h.
my_serial_port.SetCharacterSize( CHAR_SIZE_8 );
my_serial_stream.SetCharacterSize( CHAR_SIZE_8 );

// Set the desired parity type using a SetParity() method call.
// Available parity types are defined in SerialStreamConstants.h.
my_serial_port.SetParity( PARITY_ODD );
my_serial_stream.SetParity( PARITY_ODD );

// Set the number of stop bits using a SetNumOfStopBits() method call.
// Available stop bit values are defined in SerialStreamConstants.h.
my_serial_port.SetNumOfStopBits( STOP_BITS_1 ) ;
my_serial_stream.SetNumOfStopBits( STOP_BITS_1 ) ;


// Read one character from the serial port within the timeout allowed.
int timeout_ms = 25; // timeout value in milliseconds
char next_char;      // variable to store the read result

my_serial_port.ReadByte( next_char, timeout_ms );
my_serial_stream.read( next_char );


// Read one byte from the serial port.
char next_byte;
my_serial_stream.get( next_byte );



// Write a single character to the serial port.
my_serial_port.WriteByte( 'U' );
my_serial_stream << 'U' ;

// You can easily write strings.
std::string my_string = "Hello, Serial Port."

my_serial_port.Write( my_string );
my_serial_stream << my_string << std::endl ;

// And, with serial stream objects, you can easily write any type
// of object that is supported by a "<<" operator.
double radius = 2.0 ;
double area = M_PI * 2.0 * 2.0 ;

my_serial_stream << area << std::endl ;


my_serial_port.Close();
my_serial_stream.Close();
