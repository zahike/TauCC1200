/*
 * SCCB.c
 *
 *  Created on: Jun 22, 2021
 *      Author: udi
 */
#include "SCCB.h"


int writeSCCB (int WriteData)
{
	int data;

	APB[4] = 0x4;
	APB[2] = WriteData;
	APB[0] = 1;
	data = 1;
	while (data)
	{
		data = APB[1];
	};
};

int write4readSCCB (int WriteData)
{
	int data;

	APB[4] = 0x5;
	APB[2] = WriteData;
	APB[0] = 1;
	data = 1;
	while (data)
	{
		data = APB[1];
	};
};

int readSCCB (int WriteData)
{
	int data;

	APB[4] = 0x6;
	APB[2] = WriteData;
	APB[0] = 1;
	data = 1;
	while (data)
	{
		data = APB[1];
	};
	data = APB[3];
	return data;
};

