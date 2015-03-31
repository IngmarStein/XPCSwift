//
//  compat.h
//  XPCSwift
//
//  Created by Ingmar Stein on 30.03.15.
//  Copyright (c) 2015 Ingmar Stein. All rights reserved.
//

@import XPC;

// ugly clutches to make some stuff visible to Swift

extern const xpc_type_t xpc_type_bool;
extern const xpc_type_t xpc_type_int64;
extern const xpc_type_t xpc_type_uint64;
extern const xpc_type_t xpc_type_string;
extern const xpc_type_t xpc_type_double;
extern const xpc_type_t xpc_type_data;
extern const xpc_type_t xpc_type_array;
extern const xpc_type_t xpc_type_dictionary;
extern const xpc_type_t xpc_type_date;
extern const xpc_type_t xpc_type_fd;
extern const xpc_type_t xpc_type_uuid;
