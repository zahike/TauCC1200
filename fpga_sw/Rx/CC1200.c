/*
 * CC1200.c
 *
 *  Created on: Nov 21, 2021
 *      Author: udi
 */

#include "CC1200.h"

int writeSCC120 (int add, int data)
{
	int data_reg;
	int loop;
	CC1200[4] = 2;
	data_reg = add << 16;
	data_reg = data_reg + (data<<8);
	CC1200[2] = data_reg;
	CC1200[0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[1];
	};
	usleep(10);
};

int readSCC120 (int add)
{
	int data;
	int data_reg;
	int loop;
	CC1200[4] = 2;
	data_reg = add << 16;
	data_reg = data_reg + 0x00800000;
	CC1200[2] = data_reg;
	CC1200[0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[1];
	};
	data = CC1200[3];
	usleep(10);
	return data;

};

int writeLCC120 (int add, int data)
{
	int data_reg;
	int loop;
	CC1200[4] = 1;
	data_reg = add << 8;
	data_reg = data_reg + data;
	CC1200[2] = data_reg;
	CC1200[0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[1];
	};
	usleep(10);

};

int readLCC120 (int add)
{
	int data;
	int data_reg;
	int loop;
	CC1200[4] = 1;
	data_reg = add << 8;
	data_reg = data_reg + 0x00800000;
	CC1200[2] = data_reg;
	CC1200[0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[1];
	};
	data = CC1200[3];
	usleep(10);
	return data;

};


