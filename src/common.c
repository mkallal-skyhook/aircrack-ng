/*
 *  Common functions for all aircrack-ng tools
 *
 *  Copyright (C) 2006,2007 Thomas d'Otreppe
 *
 *  WEP decryption attack (chopchop) developped by KoreK
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <dirent.h>
#include <unistd.h>
#include <ctype.h>

/* Return the version number */
char * getVersion(char * progname, int maj, int min, int submin, int svnrev)
{
	char * temp;
	char * provis = calloc(1,20);
	temp = (char *) calloc(1,strlen(progname)+50);
	sprintf(temp, "%s %d.%d", progname, maj, min);
	if (submin > 0) {
		sprintf(provis,".%d",submin);
		strcat(temp,provis);
		memset(provis,0,20);
	}
	if (svnrev > 0) {
		sprintf(provis," r%d",svnrev);
		strcat(temp,provis);
	}
	free(provis);
	temp = realloc(temp, strlen(temp)+1);
	return temp;
}

//Return the mac address bytes (or null if it's not a mac address)
int getmac(char * macAddress, int strict, unsigned char * mac)
{
	char byte[3];
	int i, nbElem, n;

	if (macAddress == NULL)
		return 1;

	/* Minimum length */
	if ((int)strlen(macAddress) < 12)
		return 1;

	memset(mac, 0, 6);
	byte[2] = 0;
	i = nbElem = 0;

	while (macAddress[i] != 0)
	{
		byte[0] = macAddress[i];
		byte[1] = macAddress[i+1];

		if (sscanf( byte, "%x", &n ) != 1
			&& strlen(byte) == 2)
			return 1;

		if (!(isdigit(byte[1]) || (toupper(byte[1])>='A' && toupper(byte[1])<='F')))
			return 1;
		mac[nbElem] = n;
		i+=2;
		nbElem++;
		if (macAddress[i] == ':' || macAddress[i] == '-')
			i++;
	}

	if ((strict && nbElem != 6)
		|| (!strict && nbElem > 6))
		return 1;

	return 0;
}