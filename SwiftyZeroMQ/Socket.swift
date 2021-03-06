//
// Copyright (c) 2016 Ahmad M. Zawawi (azawawi)
//
// This package is distributed under the terms of the MIT license.
// Please see the accompanying LICENSE file for the full text of the license.
//

import Foundation

extension SwiftyZeroMQ {

    public class Socket {
        public var handle : UnsafeMutableRawPointer?

        /*
            Creates a new type of socket associated with the provided context
         */
        public init(context: Context, type : SocketType) throws {
            // Create socket
            let p : UnsafeMutableRawPointer? = zmq_socket(context.handle,
                type.rawValue)
            guard p != nil else {
                throw SwiftyZeroMQError.last
            }

            // Now we can assign socket handle safely
            handle = p!
        }

        /*
            Called by the garbage collector automatically to close the socket
         */
        deinit {
            do {
                try close()
            } catch {
                print(error)
            }
        }

        /**
            Create an outgoing connection on the current socket
         */
        public func connect(_ endpoint : String) throws {
            let result = zmq_connect(handle, endpoint)
            if result == -1 {
                throw SwiftyZeroMQError.last
            }
        }

        /**
            Closes the current socket
         */
        public func close() throws {
            let result = zmq_close(handle)
            if result == -1 {
                throw SwiftyZeroMQError.last
            }
        }

        /**
            Accept incoming connections on the current socket
         */
        public func bind(_ endpoint: String) throws {
            let result = zmq_bind(handle, endpoint)
            if result == -1 {
                throw SwiftyZeroMQError.last
            }
        }

        /**
            Stop accepting connections on the current socket
         */
        public func unbind(_ endpoint: String) throws {
            let result = zmq_unbind(handle, endpoint)
            if result == -1 {
                throw SwiftyZeroMQError.last
            }
        }

        /**
            Send a message part via the current socket
         */
        public func send(
            string  : String,
            options : SocketSendRecvOption = .none) throws
        {
            let result = zmq_send(handle, string, string.characters.count,
                options.rawValue)
            if result == -1 {
                throw SwiftyZeroMQError.last
            }
        }

        /**
            Receive a message part from the current socket
         */
        public func recv(
            bufferLength : Int = 256,
            options      : SocketSendRecvOption = .none
        ) throws -> String? {
            // Validate allowed options
            guard options.isValidRecvOption() else {
                throw SwiftyZeroMQError.invalidOption
            }

            // Read n bytes from socket into buffer
            let buffer = UnsafeMutablePointer<CChar>.allocate(
                capacity: bufferLength)
            let bufferSize = zmq_recv(handle, buffer, bufferLength,
                options.rawValue)
            if bufferSize == -1 {
                throw SwiftyZeroMQError.last
            }

            // Limit string buffer to actual buffer size
            let data = Data(bytes: buffer, count: Int(bufferSize))

            // Return read UTF8 string
            return String(data: data, encoding: String.Encoding.utf8)
        }

    }

}
